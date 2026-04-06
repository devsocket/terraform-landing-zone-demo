#!/bin/bash
# scripts/destroy_all.sh
# Destroys all Terraform layers in reverse dependency order
#
# Usage:
#   ./scripts/destroy_all.sh             — destroy all layers
#   ./scripts/destroy_all.sh --dry-run   — plan destroy only, no actual destroy
#   ./scripts/destroy_all.sh --from <layer> — resume from a specific layer
#
# Required env vars:
#   PLATFORM_SUB_ID       — devsocket-platform-sub
#   CONNECTIVITY_SUB_ID   — devsocket-connectivity-sub
#   LZ_SHARED_SUB_ID      — devsocket-lz-shared-sub
#   LZ_DEV_SUB_ID         — devsocket-lz-dev-sub
#   TFSTATE_RG            — devsocket-tfstate-rg
#   TFSTATE_SA            — stlandingzonedemostate

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour

# config
SCRIPT_DIR="$(cd "$(dirname, "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=()
DRY_RUN=false
FROM_LAYER=""
START_DEPLOYING=true

# Args
while [[ $# -gt 0 ]]; do
    case "$1" in 
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --from)
            FROM_LAYER="$2"
            START_DEPLOYING=true
            shift 2
            ;;
        *)
            echo "Uknown argument: $1"
            echo "Usage: $0 [--dry-run][--from <layer-path>]"
            exit 1
            ;;
    esac
done

# Helpers

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; ERRORS+=("$1"); }
log_step()    { echo -e "\n${CYAN}══ $1 ══${NC}"; }

# ── Validate required env vars ────────────────────────────────────────────────

check_env() {
  local missing=0
  for var in PLATFORM_SUB_ID CONNECTIVITY_SUB_ID LZ_SHARED_SUB_ID LZ_DEV_SUB_ID TFSTATE_RG TFSTATE_SA; do
    if [[ -z "${!var}" ]]; then
      log_error "Required env var $var is not set"
      missing=1
    fi
  done
  if [[ $missing -eq 1 ]]; then
    echo ""
    echo "Set all required env vars before running:"
    echo "  export PLATFORM_SUB_ID=<id>"
    echo "  export CONNECTIVITY_SUB_ID=<id>"
    echo "  export LZ_SHARED_SUB_ID=<id>"
    echo "  export LZ_DEV_SUB_ID=<id>"
    echo "  export TFSTATE_RG=devsocket-tfstate-rg"
    echo "  export TFSTATE_SA=stlandingzonedemostate"
    exit 1
  fi
}

# ── Destroy function ──────────────────────────────────────────────────────────

destroy_layer() {
  local layer_path="$1"
  local sub_id="$2"
  local extra_vars="${3:-}"
  local full_path="$REPO_ROOT/$layer_path"

  # Handle --from flag
  if [[ "$START_DESTROYING" == "false" ]]; then
    if [[ "$layer_path" == "$FROM_LAYER" ]]; then
      START_DESTROYING=true
      log_info "Resuming from: $layer_path"
    else
      log_warn "Skipping (before --from): $layer_path"
      return
    fi
  fi

  log_info "Destroying: $layer_path"

  if [[ ! -d "$full_path" ]]; then
    log_warn "Directory not found, skipping: $full_path"
    return
  fi

  cd "$full_path"
  export ARM_SUBSCRIPTION_ID="$sub_id"

  # ── Init ─────────────────────────────────────────────────────────────────

  log_info "Running terraform init..."
  if ! terraform init \
      -reconfigure \
      -input=false \
      -no-color \
      -backend-config="resource_group_name=${TFSTATE_RG}" \
      -backend-config="storage_account_name=${TFSTATE_SA}" \
      -backend-config="container_name=tfstate" \
      > /tmp/tf_init_destroy_$$.log 2>&1; then
    log_error "terraform init failed for $layer_path"
    cat /tmp/tf_init_destroy_$$.log
    cd "$REPO_ROOT"
    return
  fi
  log_success "init complete"
  
  # ── Plan destroy ──────────────────────────────────────────────────────────

  log_info "Running terraform plan -destroy..."
  local plan_cmd="terraform plan -destroy -input=false -no-color -out=/tmp/tfplan_destroy_$$"

  if [[ -n "$extra_vars" ]]; then
    plan_cmd="$plan_cmd $extra_vars"
  fi

  if ! eval "$plan_cmd" > /tmp/tf_plan_destroy_$$.log 2>&1; then
    log_error "terraform plan -destroy failed for $layer_path"
    cat /tmp/tf_plan_destroy_$$.log
    cd "$REPO_ROOT"
    return
  fi

  # Show destroy plan summary
  grep -E "^Plan:|^No changes" /tmp/tf_plan_destroy_$$.log || true
  log_success "destroy plan complete"

  # ── Apply destroy ─────────────────────────────────────────────────────────

  if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "DRY RUN — skipping destroy apply for $layer_path"
    cd "$REPO_ROOT"
    return
  fi

  log_info "Running terraform apply -destroy..."
  if ! terraform apply \
      -input=false \
      -no-color \
      /tmp/tfplan_destroy_$$ \
      > /tmp/tf_apply_destroy_$$.log 2>&1; then
    log_error "terraform destroy failed for $layer_path"
    cat /tmp/tf_apply_destroy_$$.log
    cd "$REPO_ROOT"
    return
  fi

  grep -E "^Destroy complete|^No changes" /tmp/tf_apply_destroy_$$.log || true
  log_success "destroyed: $layer_path"

  cd "$REPO_ROOT"
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
   echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║         terraform-landing-zone-demo                  ║"
  if [[ "$DRY_RUN" == "true" ]]; then
  echo "║         DESTROY ALL — DRY RUN (plan only)            ║"
  else
  echo "║         DESTROY ALL — reverse dependency order       ║"
  fi
  echo "╚══════════════════════════════════════════════════════╝"
  echo ""

  check_env

  if [[ "$DRY_RUN" == "false" ]]; then
    log_warn "This will DESTROY ALL resources in the landing zone."
    log_warn "Management groups and subscriptions will NOT be destroyed."
    echo ""
    log_warn "Type 'destroy' to confirm or Ctrl+C to cancel."
    read -r confirmation
    if [[ "$confirmation" != "destroy" ]]; then
      log_info "Cancelled."
      exit 0
    fi
  fi

  echo ""
  log_info "Starting destroy sequence..."
  echo ""

  # Common remote state vars
  RS_VARS="-var tfstate_resource_group_name=$TFSTATE_RG -var tfstate_storage_account_name=$TFSTATE_SA"

  # ── Phase 5 — App Layer (destroy first) ──────────────────────────────────

  log_info "── Phase 5: App Layer ──"

  destroy_layer \
    "apps/sample-app/dev/aks" \
    "$LZ_DEV_SUB_ID" \
    "$RS_VARS"

  destroy_layer \
    "apps/sample-app/dev/appgw" \
    "$LZ_DEV_SUB_ID" \
    "$RS_VARS"

  # ── Phase 4 — Shared Services ─────────────────────────────────────────────

  log_info "── Phase 4: Shared Services ──"

  destroy_layer \
    "shared/storage" \
    "$LZ_SHARED_SUB_ID" \
    "$RS_VARS"

  destroy_layer \
    "shared/key_vault" \
    "$LZ_SHARED_SUB_ID" \
    "$RS_VARS"

  destroy_layer \
    "shared/acr" \
    "$LZ_SHARED_SUB_ID"

  # ── Phase 3 — Connectivity ────────────────────────────────────────────────

  log_info "── Phase 3: Connectivity ──"

  destroy_layer \
    "connectivity/private-dns" \
    "$CONNECTIVITY_SUB_ID" \
    "$RS_VARS"

  destroy_layer \
    "connectivity/spokes/dev" \
    "$LZ_DEV_SUB_ID" \
    "$RS_VARS -var connectivity_subscription_id=$CONNECTIVITY_SUB_ID"

  destroy_layer \
    "connectivity/hub" \
    "$CONNECTIVITY_SUB_ID"

  # ── Phase 2 — Monitoring ──────────────────────────────────────────────────

  log_info "── Phase 2: Monitoring ──"

  destroy_layer \
    "shared/monitoring/log_analytics" \
    "$PLATFORM_SUB_ID"

  # ── Summary ───────────────────────────────────────────────────────────────

   echo ""
  if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${GREEN}║  Dry run complete — all destroy plans succeeded      ║${NC}"
    else
    echo -e "${GREEN}║  All layers destroyed successfully                   ║${NC}"
    fi
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    log_warn "Management groups and subscriptions were NOT destroyed"
    log_warn "Clean those up manually in the Azure portal if needed"
  else
    echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  Destroy completed with errors                       ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    log_error "Failed layers:"
    for err in "${ERRORS[@]}"; do
      echo -e "  ${RED}✗${NC} $err"
    done
    echo ""
    log_warn "Use --from <layer-path> to resume from a specific layer"
    log_warn "Example: ./destroy_all.sh --from shared/storage"
    exit 1
  fi

  echo ""
}

main "$@"
#!/usr/bin/env bash
# scripts/deploy_all.sh
# Deploys all terraform layers in dependency order

#usage:
#   ./scripts/deploy_all.sh              — full deploy (plan + apply all layers)
#   ./scripts/deploy_all.sh --dry-run    — plan only, no apply
#   ./scripts/deploy_all.sh --from <layer> — resume from a specific layer
#
# Required env vars:
#   PLATFORM_SUB_ID       — devsocket-platform-sub
#   CONNECTIVITY_SUB_ID   — devsocket-connectivity-sub
#   LZ_SHARED_SUB_ID      — devsocket-lz-shared-sub
#   LZ_DEV_SUB_ID         — devsocket-lz-dev-sub
#   TFSTATE_RG            — devsocket-tfstate-rg
#   TFSTATE_SA            — stlandingzonedemostate
set -euo pipefail

#colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# config
SCRIPT_DIR = "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=()
DRY_RUN=false
FROM_LAYER=""
START_DEPLOYING=true

# Args
while [[ $# -gt 0]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --from)
            FROM_LAYER="$2"
            START_DEPLOYING=false
            shift 2
            ;;
        *)
        echo "unknown argument: $1"
        echo "Usage: $0 [--dry-run] [--from <layer-path>]"
        exit 1
    esac
done

# Helpers
log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; ERRORS+=("$1"); }
log_step()    { echo -e "\n${CYAN}══ $1 ══${NC}"; }

# Validate required env vars
check_env() {
    local missing=0
    for var in PLATFORM_SUB_ID CONNECTIVITY_SUB_ID LZ_SHARED_SUB_ID LZ_DEV_SUB_ID TFSTATE_RG TFSTATE_SA; do
        if [[ -z "${var}" ]]; then
            log_error "Required env var $var is not set"
            missing=1
        fi
    done

    if [[$missing -eq 1]]; then
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

# Deploy function
deploy_layer(){
    local layer_path="$1"
    local sub_id="$2"
    local extra_vars="${3:-}"
    local full_path="$REPO_ROOT/$layer_path"

    # Handle --from flag - skip layers before the specified one
    if [["$START_DEPLOYING" == "false" ]]; then
        if [[ "$layer_path" == "$FROM_LAYER"]]; then
            START_DEPLOYING=true
            log_info "Resuming from: $layer_path"
        else
            log_info "Skipping (before -from): $layer_path"
            return
        fi
    fi

    log_step "Layer: $layer_path"

    if [[ ! -d "$full_path" ]]; then
        log_warn "Not found, skipping: $layer_path"
        return
    fi

    cd "$full_path"
    export ARM_SUBSCRIPTION_ID="$sub_id"

    # Init
    log_info "Running terraform init..."
    if ! terraform init \
        -reconfigure \
        -input=false \
        -no-color \
        -backend-config="resource_group_name=${TFSTATE_RG}" \
        -backend-config="storage_account_name=${TFSTATE_SA}" \
        -backend-config="container_name=tfstate" \
        > /tmp/tf_init_$$.log 2>&1; then
    log_error "terraform init failed for $layer_path"
    cat /tmp/tf_init_$$.log
    cd "$REPO_ROOT"
    return
    fi
    log_success "init complete"

    # Plan
    log_info "Running terraform plan..."
    local plan_cmd="terraform plan -input=false -no-color -out=/tmp/tfplan_$$"

    if [[ -n "$extra_vars" ]]; then
        plan_cmd="$plan_cmd $extra_vars"
    fi

    if ! eval "$plan_cmd" > /tmp/tf_plan_$$.log 2>&1; then
        log_error "terraform plan failed for $layer_path"
        cat /tmp/tf_plan_$$.log
        cd "$REPO_ROOT"
        return
    fi

    #show plan summary
    grep -E "^Plan: |^No changes" /tmp/tf_plan_$$.log || true
    log_success "plan complete"

    # Apply
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run enabled, skipping apply for $layer_path"
        cd "$REPO_ROOT"
        return
    fi

    log_info "Running terraform apply..."
    if ! terraform apply \
        -input=false \
        -no-color \
        /tmp/tfplan_$$ \
        > /tmp/tf_apply_$$.log 2>&1; then
        log_error "terraform apply failed for $layer_path"
        cat /tmp/tf_apply_$$.log
        cd "$REPO_ROOT"
        return
    fi

    # show apply summary
    grep -E "^Apply complete!|^changes to output" /tmp/tf_apply_$$.log || true
    log_success "apply complete: $layer_path"

    cd "$REPO_ROOT"
}

# Main
main() {
    echo ""
    echo "terraform-landing-zone-demo"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "DRY RUN - no changes will be applied"
    else
        echo "Deploying all layers..."
    fi
    echo ""

    check_env

    if [[ "$DRY_RUN" == "false" ]]; then
        log_warn "This will deploy all layers to azure."
        log_warn "Type 'deploy' to confirm or Ctrl+C to cancel."

        read -c confirmation
        if [[ "$confirmation" != "deploy" ]]; then
            log_info "Deployment cancelled by user."
        fi
    fi

    echo ""

    # common remote state vars passed to layers that need them
    RS_VARS="-var=remote_state_resource_group=${TFSTATE_RG} -var=remote_state_storage_account=${TFSTATE_SA}"

    # - Phase 1 - Monitoring

    deploy_layer \
        "shared/monitoring/log_analytics" \
        "$PLATFORM_SUB_ID"

    # Phase 2 - Hub Network
    deploy_layer \
        "connectivity/hub" \
        "$CONNECTIVITY_SUB_ID"
    
    # Phase 3 - spoke network
    deploy_layer \
        "connectivity/spokes/dev" \
        "$LZ_DEV_SUB_ID" \
        "$RS_VARS -var connectivity-subscription_id=${CONNECTIVITY_SUB_ID}"

    # phase 3b - private DNS
    deploy_layer \
        "connectivity/private-dns" \
        "$CONNECTIVITY_SUB_ID" \
        "$RS_VARS"
    
    # Phase 4 - shared services
    deploy_layer \
        "shared/key_valut" \
        "$LZ_SHARED_SUB_ID" \
        "$RS_VARS"
    
    deploy_layer \
        "shared/acr" \
        "$LZ_SHARED_SUB_ID" \
        "$RS_VARS"

    deploy_layer \
        "shared/storage" \
        "$LZ_SHARED_SUB_ID" \
        "$RS_VARS"

    # phase 5 - app layer
    deploy_layer \
        "apps/sample-app/dev/appgw" \
        "$LZ_DEV_SUB_ID" \
        "$RS_VARS"

    
    deploy_layer \
        "apps/sample-app/dev/aks" \
        "$LZ_DEV_SUB_ID" \
        "$RS_VARS"

    # Summary

    echo ""
    if [[ ${#ERRORS[@]} -eq 0 ]]; then
         echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
        if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${GREEN}║  Dry run complete — all plans succeeded              ║${NC}"
        else
        echo -e "${GREEN}║  All layers deployed successfully                    ║${NC}"
        fi
        echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
        if [[ "$DRY_RUN" == "false" ]]; then
            echo ""
            log_warn "Next steps — Pass 2 role assignments:"
            echo ""
            echo "  1. Get kubelet identity:"
            echo "     cd apps/sample-app/dev/aks"
            echo "     terraform output kubelet_identity_object_id"
            echo ""
            echo "  2. Update shared/acr/variables.tf:"
            echo "     enable_aks_pull_access         = true"
            echo "     aks_kubelet_identity_object_id = \"<kubelet-object-id>\""
            echo "     cd shared/acr && terraform apply"
            echo ""
            echo "  3. Update shared/key_vault/variables.tf role_assignments block"
            echo "     cd shared/key_vault && terraform apply $RS_VARS"
            echo ""
            echo "  4. Get kubectl access:"
            echo "     az aks get-credentials --resource-group rg-aks-dev --name aks-devsocket-dev --overwrite-existing"
        fi
    else
        echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  Deploy completed with errors                        ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        log_error "Failed layers:"
        for err in "${ERRORS[@]}"; do
        echo -e "  ${RED}✗${NC} $err"
        done
        echo ""
        log_warn "Use --from <layer-path> to resume from a specific layer"
        log_warn "Example: ./deploy_all.sh --from connectivity/spokes/dev"
        exit 1
    fi
  echo ""
}

main "$@"
#!/usr/bin/env bash

# Runs terraform fmt -check and terraform validate across all layers
# Usgae ./scripts/validate_all.sh
#No azure credentials required - validate runs locally without backend

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helpers
SCRIPT_DIR = "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT = "$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=()
WARNINGS=()
PASS=0
FAIL=0

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $1"; PASS=$((PASS+1)); }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; WARNINGS+=("$1"); }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; ERRORS+=("$1"); FAIL=$((FAIL+1)); }

# Layers
# All deployable root modules in landing zone repo in dependency order
LAYERS=(
    "shared/monitoring"
    "shared/key_vault"
    "shared/acr"
    "shared/storage"
    "connectivity/hub"
    "connectivity/spokes/dev"
    "apps/sample-app/dev/aks"
    "apps/sample-app/dev/appgw"
)

# Format Check
fmt_check() {
    local path = "$1"
    local full_path = "$REPO_ROOT/$path"

    if terraform fmt -check -recursive "$full_path" > /dev/null 2>&1; then
        log_success "fmt OK: $path"
    else
        log_error "fmt FAIL: $path -run 'terraform fmt -recursive $full_path' to fix"
}

# Validation
validate_layer(){
    local path = "$1"
    local full_path = "$REPO_ROOT/$path"

    if [[ ! -d "$full_path" ]]; then
        log_warn "Not found, skipping: $path"
        return
    fi

    cd "$full_path"

    # Init with backend=false - no azure credentials required
    # Download providers locally without connecting to state backend

    if ! terraform init \
        -backend=false \
        -input = false \
        -no-color > /tmp/tf_init_validate_$$.log 2>&1; then
        log_error "init FAIL: $path"
        cat /tmp/tf_init_validate_$$.log
        cd "$ROOT_REPO"
        return 
    fi

    if terraform validate -no-color > /tmp/tf_init_validate_$$.log 2>&1; then
        log_success "validate OK: $path"
    else 
        log_error "validate FAIL: $path"
        cat /tmp/tf_init_validate_$$.log
    fi

    cd "$REPO_ROOT"
}

# module fmt check (commons module)
module_fmt_check() {
    local common_modules_root
    common_modules_root="$(cd "$REPO_ROOT/../terraform-common-modules" && pwd 2>/dev/null)" || {
        log_warn "terraform-common-modules not found at ../terraform-common-modules -skipping module fmt check"
        return
    }


    log_info "Checking fmt in terraform-common-modules..."

    if terraform fmt -check -recursive "$common_modules_root" > /dev/null 2>&1; then
        log_success "fmt OK: terraform-common-modules (all modules)"
    else 
        log_error "fmt FAIL: terraform-common-modules - run 'terraform fmt -recursive $common_modules_root'"
    fi
}

# main

main() {
    echo ""
    echo " terraform-landing-zone-demo"
    echo " VALIDATE ALL LAYERS"
    echo ""

    #Check terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}ERROR: terraform not installed in PATH${NC}"
        exit 1
    fi

    log_info "Terraform version: $(terraform version -json | python3 -c 'import sys,json; print(json.load(sys.stdin)["terraform_version"])' 2>/dev/null || terraform version | head -1)"
    echo ""

    # Format checks - no init needed
    log_info "-format check---"
    module_fmt_check
    for layer in "${LAYERS[@]}"; do
        validate_layer "$layer"
    done
    echo ""

    # Summary
    echo ""
    printf "RESULTS: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}%-24s||\n" "$PASS" "$FAIL" ""
    echo ""

    if[[ ${WARNINGS[@]} -gt 0 ]]; then
        echo ""
        log_warn "Warnings:"
        for w in "${WARNINGS[@]}";do
            echo -e " ${YELLOW} ${NC} $w"
        done
    fi

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo ""
        log_error "Failed checks:"
        for e in "${ERRORS[@]}"; do
            echo -e " ${RED}x${NC} $err"
        done
        echo ""
        exit 1
    fi

    echo ""
    log_success "All checks passed - safe to deploy"
    echo ""
}

main "$@"
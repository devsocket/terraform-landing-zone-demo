# ⚙️ Implementation Details — Azure Landing Zone (Terraform)

> This document contains the **low-level implementation, deployment steps, and operational details** for the Terraform-based Azure Landing Zone.
> For architecture decisions, trade-offs, and design rationale, refer to the main `README.md`.

---

## 📂 Repository Structure

```
terraform-landing-zone-demo/
│
├── global/                          # Tenant-wide: naming, tags, providers, versions
├── mgmt-groups/                     # Management group hierarchy + associations
├── connectivity/                    # Hub VNet, DNS, spoke VNets
├── shared/                          # ACR, Key Vault, Storage, Monitoring
├── apps/                            # Workloads (AKS + App Gateway)
├── scripts/                         # Automation scripts
└── .github/workflows/               # CI/CD pipelines
```

---

## 🧱 Subscription Layout

| Subscription                 | Purpose                                      |
| ---------------------------- | -------------------------------------------- |
| `devsocket-platform-sub`     | Shared platform services (state, monitoring) |
| `devsocket-connectivity-sub` | Hub networking and DNS                       |
| `devsocket-lz-shared-sub`    | Shared services (ACR, Key Vault, Storage)    |
| `devsocket-lz-dev-sub`       | Development workloads                        |
| `devsocket-lz-prod-sub`      | Production workloads                         |

---

## ⚙️ Prerequisites

* Terraform >= 1.6.0
* Azure CLI >= 2.50.0
* Bash (Linux/macOS or Git Bash on Windows)
* Azure Service Principal with required permissions

---

## 🚀 Deployment Guide

### 1. Bootstrap Remote State

```bash
chmod +x scripts/bootstrap_state.sh
./scripts/bootstrap_state.sh
```

Creates:

* Resource Group: `devsocket-tfstate-rg`
* Storage Account: `stlandingzonedemostate`

---

### 2. Configure Environment Variables

```bash
export PLATFORM_SUB_ID="<platform-sub-id>"
export CONNECTIVITY_SUB_ID="<connectivity-sub-id>"
export LZ_SHARED_SUB_ID="<shared-sub-id>"
export LZ_DEV_SUB_ID="<dev-sub-id>"
export TFSTATE_RG="devsocket-tfstate-rg"
export TFSTATE_SA="stlandingzonedemostate"
```

(Optional)

```bash
source .env.local
```

---

### 3. Validate Configuration

```bash
bash scripts/validate_all.sh
```

Runs:

* `terraform fmt -check`
* `terraform validate`

---

### 4. Plan Deployment

```bash
bash scripts/deploy_all.sh --dry-run
```

---

### 5. Apply Deployment

```bash
bash scripts/deploy_all.sh
```

---

### 6. Post-Deployment Configuration (AKS Integration)

#### Retrieve kubelet identity

```bash
cd apps/sample-app/dev/aks
terraform output kubelet_identity_object_id
```

---

#### Configure ACR access

Update:

```
shared/acr/variables.tf
```

```hcl
enable_aks_pull_access         = true
aks_kubelet_identity_object_id = "<kubelet-object-id>"
```

```bash
cd shared/acr
terraform apply
```

---

#### Configure Key Vault access

Update:

```
shared/key_vault/variables.tf
```

```hcl
role_assignments = {
  "aks-workload" = {
    role         = "Key Vault Secrets User"
    principal_id = "<kubelet-object-id>"
  }
}
```

```bash
terraform apply \
  -var tfstate_resource_group_name=$TFSTATE_RG \
  -var tfstate_storage_account_name=$TFSTATE_SA \
  -var tfstate_subscription_id=$PLATFORM_SUB_ID
```

---

#### Access AKS cluster

```bash
az aks get-credentials \
  --resource-group rg-cc-aks-dev \
  --name aks-cc-devsocket-dev \
  --overwrite-existing
```

---

## 💥 Destroy Environment

```bash
bash scripts/destroy_all.sh
```

---

## 🧪 Scripts Reference

| Script               | Purpose                          |
| -------------------- | -------------------------------- |
| `bootstrap_state.sh` | Initialize remote state backend  |
| `validate_all.sh`    | Validate Terraform across layers |
| `deploy_all.sh`      | Plan/apply deployment            |
| `destroy_all.sh`     | Destroy infrastructure           |

---

## 🔁 CI/CD Pipelines

### Workflows

| Workflow                | Trigger          | Purpose       |
| ----------------------- | ---------------- | ------------- |
| `terraform-plan.yml`    | feature/*, fix/* | Plan changes  |
| `terraform-apply.yml`   | upgrade/*        | Apply changes |
| `terraform-destroy.yml` | Manual           | Destroy infra |

---

### Trigger Deployment

```bash
git checkout -b upgrade/deploy-$(date +%Y%m%d)
git add .
git commit -m "deploy: update infra"
git push origin upgrade/deploy-$(date +%Y%m%d)
```

---

## 🔐 GitHub Configuration

### Required Secrets

* `AZURE_CLIENT_ID`
* `AZURE_TENANT_ID`
* Subscription IDs

### Required Variables

* `TFSTATE_RG`
* `TFSTATE_SA`
* `TF_VERSION`

---

## 📦 Module Source

Terraform modules sourced from:

```
github.com/devsocket/terraform-common-modules
```

Version:

```
v1.0.0
```

---

## 📌 Notes

* Deployment is **layered and dependency-aware**
* Avoid manual Terraform runs outside scripts (to maintain consistency)
* CI/CD pipelines are the preferred deployment method
* State is isolated per layer for safer operations

---

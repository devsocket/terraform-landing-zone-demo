# terraform-landing-zone-demo

> **Enterprise-grade Azure Landing Zone — Infrastructure as Code.**  
> Implements the [Microsoft Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) using Terraform.  
> Designed for regulated, multi-subscription Azure environments requiring governance at scale.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Tenant Root Group                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Management Groups                        │   │
│  │                                                           │   │
│  │   ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │   │
│  │   │  Platform   │  │ Landing Zones│  │   Sandboxes   │  │   │
│  │   │   (shared)  │  │  (workloads) │  │  (dev/test)   │  │   │
│  │   └─────────────┘  └──────────────┘  └───────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Connectivity (Hub-Spoke)                      │ │
│  │                                                            │ │
│  │   ┌─────────────────┐    peering    ┌──────────────────┐  │ │
│  │   │   Hub VNet      │◄─────────────►│  Dev Spoke VNet  │  │ │
│  │   │  (centralised   │               │  (workload       │  │ │
│  │   │   firewall/DNS) │               │   isolation)     │  │ │
│  │   └────────┬────────┘               └──────────────────┘  │ │
│  │            │ Private DNS                                   │ │
│  │   ┌────────▼────────┐                                     │ │
│  │   │ Private DNS     │                                     │ │
│  │   │ Zones + Links   │                                     │ │
│  │   └─────────────────┘                                     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Shared Services                               │ │
│  │                                                            │ │
│  │   ┌──────────┐   ┌───────────┐   ┌──────────────────┐    │ │
│  │   │   ACR    │   │ Key Vault │   │  Log Analytics   │    │ │
│  │   │(Container│   │  (secrets │   │  (observability  │    │ │
│  │   │ Registry)│   │ + certs)  │   │   backbone)      │    │ │
│  │   └──────────┘   └───────────┘   └──────────────────┘    │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
terraform-landing-zone-demo/
│
├── global/                     # Tenant-wide: naming, tags, providers, versions
│   ├── naming.tf               # Centralised naming convention module
│   ├── tags.tf                 # Mandatory tag policy (env, owner, cost-centre)
│   ├── providers.tf            # AzureRM, AzureAD, Kubernetes, Helm provider config
│   ├── variables.tf            # Global input variables
│   └── versions.tf             # Provider version constraints
│
├── mgmt-groups/
│   └── main/
│       ├── hierarchy/          # Management group tree (Platform / LZ / Sandbox)
│       │   └── main.tf
│       └── sub-assoc/          # Subscription-to-management-group associations
│           └── main.tf
│
├── connectivity/
│   ├── hub/                    # Hub VNet — centralised egress, firewall, DNS resolution
│   ├── private-dns/            # Private DNS zones + VNet links for PaaS services
│   └── spokes/
│       └── dev/                # Dev spoke VNet — peered to hub, workload isolation
│
├── shared/
│   ├── acr/                    # Azure Container Registry (private endpoint)
│   ├── key_vault/              # Platform Key Vault (private endpoint + RBAC)
│   └── monitoring/
│       └── log_analytics/      # Log Analytics workspace (centralised observability)
│
└── scripts/
    └── bootstrap_state.sh      # Bootstraps Azure remote state (Storage Account + container)
```

---

## 🚀 Deployment Order

> Terraform modules must be applied in dependency order. Each layer depends on the one above it.

```
1. scripts/bootstrap_state.sh       # Create remote state backend first
2. global/                          # Naming, tags, provider config
3. mgmt-groups/main/hierarchy/      # Management group structure
4. mgmt-groups/main/sub-assoc/      # Assign subscriptions to groups
5. connectivity/hub/                # Hub VNet
6. connectivity/private-dns/        # Private DNS zones
7. connectivity/spokes/dev/         # Spoke VNet + peering to hub
8. shared/monitoring/log_analytics/ # Observability backbone
9. shared/key_vault/                # Secrets management
10. shared/acr/                     # Container registry
```

### Bootstrap Remote State

```bash
# Run once before any terraform init/apply
chmod +x scripts/bootstrap_state.sh
./scripts/bootstrap_state.sh
```

This script provisions the Azure Storage Account and blob container used as Terraform remote state backend across all modules.

### Apply a Module

```bash
cd connectivity/hub
terraform init
terraform plan -var-file="../../global/terraform.tfvars"
terraform apply -var-file="../../global/terraform.tfvars"
```

---

## ⚙️ Requirements

| Dependency | Version |
|---|---|
| Terraform | `>= 1.6.0` |
| AzureRM provider | `3.117.1` |
| AzureAD provider | `3.8.0` |
| Helm provider | `2.17.0` |
| Kubernetes provider | `>= 2.38.0` |
| Azure CLI | `>= 2.50.0` |

---

## 🔑 Key Architecture Decisions & Tradeoffs

**Hub-spoke over Virtual WAN**  
Chose traditional hub-spoke topology over Azure Virtual WAN for this reference architecture. Hub-spoke gives full Terraform control over every resource and avoids Virtual WAN's managed service abstraction — the tradeoff is more explicit peering management, which is acceptable for a team owning the full platform.

**Per-layer remote state over monolithic state**  
Each deployment layer (connectivity, shared, mgmt-groups) uses its own Terraform state file rather than a single shared state. This reduces blast radius from state corruption, allows independent apply/destroy cycles, and supports team-based ownership of separate layers. The tradeoff is cross-layer data sharing via `terraform_remote_state` data sources instead of direct references.

**Private endpoints on all PaaS services**  
ACR, Key Vault, and Log Analytics are all provisioned with private endpoints and public access disabled. This is non-negotiable in regulated environments (gaming/lottery, finance, healthcare). The operational tradeoff is that pipeline agents must be VNet-integrated or use self-hosted runners with VNet access.

**Centralised naming via `global/naming.tf`**  
All resource names are derived from a single naming convention module rather than hardcoded per-module. This enforces consistency (e.g. `vnet-hub-prod-uksouth-001`) and makes environment promotion (dev → staging → prod) a single variable change. Inspired by the [Azure Naming Tool](https://github.com/mspnp/AzureNamingTool).

**Management group hierarchy mirrors CAF**  
The management group structure (Platform / Landing Zones / Sandboxes) mirrors the [Microsoft CAF enterprise-scale hierarchy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups) rather than a flat subscription model — enabling Azure Policy inheritance at scale without per-subscription policy duplication.

---

## 🔗 Module Source

Infrastructure modules are sourced from [`terraform-common-modules`](https://github.com/devsocket/terraform-common-modules) — a companion reusable module library.

```hcl
module "hub_vnet" {
  source = "github.com/devsocket/terraform-common-modules//modules/connectivity/hub_vnet?ref=v1.0.0"
  # ...
}
```

---

## 🔗 References

- [Microsoft Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Azure Landing Zone Design Principles](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-principles)
- [AZ-305: Azure Solutions Architect Expert](https://learn.microsoft.com/en-us/credentials/certifications/azure-solutions-architect/)
- [Terraform AzureRM Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

## 👤 Author

**V Sudheer Kumar K** — Senior Technical Lead | Azure Solutions Architect (AZ-104, AZ-305)  
[GitHub](https://github.com/devsocket) · [LinkedIn](https://linkedin.com/in/sudheer44)
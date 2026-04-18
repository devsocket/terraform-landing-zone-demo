# Azure Landing Zone Demo (Terraform)

**A production-style Azure landing zone built using Terraform.**

This repo is a practical implementation of a multi-subscription setup aligned with Cloud Adoption Framework (CAF) principles, but simplified to stay usable in a pay-as-you-go environment.

The focus here is not just provisioning infrastructure, but structuring it in a way that scales, stays maintainable, and doesn’t get unnecessarily expensive.

---

## What this project is trying to solve

Most landing zone examples either:

* stay too high-level (diagrams, no real code), or
* go full enterprise (too complex to actually run)

This sits somewhere in between.

It models a setup where:

* multiple environments need to be isolated (dev / prod)
* platform resources are shared safely
* workloads run on AKS
* identity and secrets are handled without hardcoding anything
* everything is deployable end-to-end using Terraform

---

## High-level architecture


![Azure Landing Zone Architecture](/docs/architecture.png)
> Full-resolution diagram is available at '/docs/architecture.png'

At a high level, the setup includes:

* Management group hierarchy for governance
* Separate subscriptions for platform, connectivity, shared services, and workloads
* Hub-spoke networking with centralized DNS
* Shared services (ACR, Key Vault, Storage, Log Analytics)
* AKS-based workload behind Application Gateway (WAF + AGIC)
* GitHub Actions for CI/CD using OIDC (no stored credentials)

---

## Why it’s structured this way

This isn’t a “copy CAF blindly” setup. Some decisions were adjusted to keep things realistic.

### Fewer subscriptions than standard CAF

CAF suggests more separation, but that gets expensive quickly.
Here it’s reduced to a smaller set while still keeping clear boundaries between:

* platform
* connectivity
* shared services
* workloads

Good enough for most mid-size setups, without burning budget early.

---

### Hub-spoke instead of Virtual WAN

Virtual WAN is great, but it abstracts too much and gets expensive fast.

Hub-spoke:

* gives full control in Terraform
* is easier to reason about when debugging
* is cheaper at smaller scale

Trade-off is more manual setup (peering, routing), which is acceptable here.

---

### No Azure Firewall (on purpose)

Firewall was intentionally left out.

Reason:

* baseline cost is high for low-throughput environments
* most early-stage or mid-scale systems don’t need it immediately

Instead:

* NSGs + UDRs are used
* route tables are already in place

If needed later, a firewall can be inserted without redesigning everything.

---

### Per-layer Terraform state

Each layer (connectivity, shared, apps, etc.) has its own state.

This helps with:

* reducing blast radius
* allowing partial deployments
* separating ownership if teams grow

Downside is slightly more coordination, but worth it in practice.

---

### Workload identity instead of secrets

AKS is configured with OIDC and workload identity.

That means:

* no secrets stored in pods
* no Key Vault credentials passed around

Everything is handled via federated identity and RBAC.

This adds a bit of setup complexity, but avoids a lot of long-term problems.

---

## Security approach (simplified)

* RBAC everywhere (including Key Vault)
* No access policies
* Private endpoints + private DNS
* WAF enabled on ingress
* Managed identities for all service interactions

Nothing fancy, just consistent.

---

## Cost mindset

This was built with cost in mind from the start.

Examples:

* no Azure Firewall baseline cost
* shared Log Analytics instead of multiple workspaces
* minimal SKU choices unless required

Roughly speaking, this kind of setup can run without hitting enterprise-level monthly costs, while still being structured properly.

---

## CI/CD approach

GitHub Actions is used with OIDC federation.

* no client secrets stored
* plans run on feature branches
* apply runs via controlled branches

This keeps deployments simple and avoids credential management headaches.

---

## What to look at if you're reviewing this

If you're short on time, these parts matter most:

* `/connectivity` → hub-spoke setup
* `/shared` → how common services are structured
* `/apps/.../aks` → workload identity + cluster setup
* `.github/workflows` → CI/CD approach

---

## What’s intentionally not covered

This is not a full enterprise blueprint.

Things not included (on purpose):

* policy as code (Azure Policy)
* advanced security tooling (Defender, Sentinel)
* multi-region failover
* full production hardening

Those can be layered on top, but would make the example harder to run and understand.

---

## Running it

Full deployment steps and scripts are in:

👉 `IMPLEMENTATION_DETAILS.md`

That doc covers:

* prerequisites
* environment setup
* deployment scripts
* CI/CD usage

---

## Final note

This repo is meant to reflect how I would actually structure a landing zone for a real project — not just pass an exam or match a reference diagram.

There are trade-offs here, and they’re intentional.

---

## Author

**V Sudheer Kumar K**

`Azure / Cloud / Platform Engineering`

[GitHub](https://github.com/devsocket) • 
[LinkedIn](https://linkedin.com/in/sudheer44)
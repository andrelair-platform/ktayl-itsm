# Deployment Architecture — decided direction (before we build)

> **Purpose:** lock the *how it deploys* decision now, so when work on GLPI starts the direction is
> already clear. Decided against the platform's GitOps framework (see
> `minicloud-platform-docs` → Developer Platform → *GitOps Directory Patterns* + *Custom Images*).

## The decision (one line)

**GLPI deploys as a GAP wrapper Helm chart at `services/ktayl-itsm/helm/` in `minicloud-gitops`,
using a custom image built from THIS repo, on product board #16.** Not raw manifests, not a stock
vendor chart.

## The three-part pattern (same shape as retrieva)

```
ktayl-itsm (this repo)          → custom GLPI image (Dockerfile: CA trust + ITIL plugins + PHP config)
minicloud-gitops               → services/ktayl-itsm/helm/  (GAP wrapper chart = the deployment)
GitHub Project #16             → the backlog
```

## Why a wrapper chart (`services/`), not the other two

Applying the one-line test — *"is there real templating / reuse / packaging value?"* → **strongly yes.**

| Signal | GLPI | ⇒ |
|---|---|---|
| Complexity | web app **+ MariaDB + PVC + cron + secrets + ingress + netpol** (full stateful app) | too much for raw manifests |
| Custom image? | yes — CA trust + GLPI plugins/marketplace + PHP config | it's *our* customized app, so we author the deployment |
| Vary across dev/prod? | yes (real product, own backlog) | templating pays off |
| Reuse the shared library? | probes, resources, netpol, ingress, rollout via `minicloud-app-deployment` | the wrapper chart is the payoff |

- **NOT `helm-values/` (stock vendor chart):** that's for charts we configure but don't build. GLPI
  has no strong official chart **and** we bake a custom image (plugins) → we author the deployment.
- **NOT raw `manifests/` (like OnlyOffice):** OnlyOffice is raw because it's ~4 static objects, single
  instance, an adjunct to Nextcloud. GLPI is the opposite — a standalone, stateful, multi-object
  product with dev+prod. That's exactly what wrapper charts are for.

## What the wrapper chart will contain

- **GLPI web workload** → via the shared `minicloud-app-deployment` library subchart.
- **MariaDB** → a StatefulSet in the wrapper's `templates/` (same pattern as retrieva's Postgres) — or
  a stock `mariadb` via `helm-values/` if we decide not to own it. Decide at the architecture gate.
- **Custom image** → from this repo (`ktayl-itsm`): CA trust, ITIL v4 plugins, PHP/Apache config.
- **`values-dev.yaml` / `values-prod.yaml`** overlays; ESO→Vault for DB/app secrets; NetworkPolicy;
  Ingress + Certificate; Kargo promotion (dev→prod).

## CA trust

Since we're building a custom image anyway, CA trust can be baked (`ARG CA_CERT`) **or** injected at
runtime via `trust-manager` (mount `minicloud-ca-bundle` + `NODE_EXTRA_CA_CERTS`/OS trust dir). Prefer
**runtime** unless a build-time reason (plugins needing TLS at build) forces baking — the image is still
justified by the plugins. See *Custom Images → CA trust: bake vs runtime*.

## Guardrails

- **ktayl-solution IS** product (IS Foundations). **Excludes Retrieva** (separate product).
- Deployment config lives in `minicloud-gitops` (chart + values + manifests + apps); this repo owns the
  **image + app config**, not the deploy wiring.
- CODEOWNERS-gated prod; env-agnostic image (runtime config); GAP wrapper standard.

# AGENTS.md — ktayl-itsm (GLPI)

Tiny repo-specific context. Org rules (`minicloud-gitops/.claude/rules/*`) still apply.

## Policy
- **ktayl-solution IS** product (IS Foundations, board **#16**) — GLPI-based ITSM (ITIL v4, CMDB,
  incident/request, SLA, helpdesk). **NEVER involve Retrieva** (separate product).
- **Deployment direction is already decided** — see [`docs/deployment-architecture.md`](docs/deployment-architecture.md):
  GLPI ships as a **GAP wrapper Helm chart** at `services/ktayl-itsm/helm/` in `minicloud-gitops`,
  using a **custom image built from THIS repo** (CA trust + ITIL plugins + PHP config). **Not** raw
  manifests, **not** a stock vendor chart.
- This repo owns the **image + app config**; the **deploy wiring** (chart/values/manifests/apps) lives
  in `minicloud-gitops`. Env-agnostic image, CODEOWNERS-gated prod, Kargo dev→prod.

## Status
Scaffold. BMAD per-product. Deployment architecture decided (above); build not started.

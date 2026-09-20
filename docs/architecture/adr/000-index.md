# ADR Log — ktayl ITSM (GLPI) (#16)

> **BMAD/SA artefact.** Architecture decisions + rationale. **Status: DRAFT / Proposed.**

| ADR | Title | Status | Owner |
|---|---|---|---|
| [001](#adr-001) | GLPI as the ITSM/ITIL tool (off-the-shelf, not custom-built) | Proposed | SA/TL |
| [002](#adr-002) | Deploy as a GAP wrapper chart + custom image | Accepted | SA/TL |
| [003](#adr-003) | CMDB scoped to software/services/logical + cloud (BYOD — no HW fleet) | Proposed | SA/TL |
| [004](#adr-004) | Own MariaDB in the wrapper vs a stock chart | Proposed | SA/TL |
| [005](#adr-005) | Seed/sync the CMDB from Backstage + k8s (not hand-maintained) | Proposed | SA/TL |
| [006](#adr-006) | Alert→ticket via authenticated, idempotent Alertmanager webhook | Proposed | SA/TL |
| [007](#adr-007) | Keep scope to service-management (Plane = PM, Prometheus = metrics) | Proposed | SA/TL |

## ADR-001 — GLPI as the ITSM tool {#adr-001}
**Context.** The IS needs incident/request/problem/change + SLA + CMDB + self-service. Building this is
years of work; mature OSS exists.
**Decision.** Use **GLPI** (ITIL v4, OSS, self-hostable, French-origin — apt for a FR insurer, strong
CMDB + plugins). Alternatives: iTop (heavier), Zammad (helpdesk-only, weak CMDB), SNow/Jira SM (SaaS/paid,
against self-hosted principle). This is **config, not code**.
**Consequences.** Fast, credible ITIL layer; DORA incident evidence. Cost: a PHP/MariaDB app to run + plugin supply-chain care.

## ADR-002 — GAP wrapper chart + custom image {#adr-002}
**Context/Decision.** **Decided** in [deployment-architecture.md](../deployment-architecture.md): GLPI
deploys as a **GAP wrapper Helm chart** (`services/ktayl-itsm/helm/`) from a **custom image** (CA trust +
pinned plugins + PHP config), dev+prod, ESO secrets, ingress+cert, netpol, Kargo.
**Consequences.** Matches the org standard (retrieva shape); no stock-chart drift; we own the image.

## ADR-003 — CMDB scope = software/services/logical + cloud (BYOD) {#adr-003}
**Context.** ktayl is **BYOD — no managed hardware** (`project-governance.md`).
**Decision.** The CMDB records **applications · microservices · databases · namespaces · domains ·
SaaS/external** with owners + dependencies — **not** a hardware/endpoint fleet.
**Consequences.** A cleaner, honest CMDB that reflects what actually runs; aligns with identity-is-the-
perimeter. **Revisit** if endpoints ever come in scope (Fleet/osquery successor).

## ADR-004 — Own MariaDB in the wrapper {#adr-004}
**Context.** GLPI needs MySQL/MariaDB.
**Decision (proposed).** Run MariaDB as a **StatefulSet in the wrapper** `templates/` (retrieva-Postgres
pattern) for lifecycle control + backup wiring, rather than a separate stock chart. **Confirm at the
architecture gate** (a stock `mariadb` chart via `helm-values/` is the fallback if we'd rather not own it).
**Consequences.** One deployable unit, backup in the same set; slightly more to maintain.

## ADR-005 — CMDB seeded/synced from Backstage + k8s {#adr-005}
**Context.** A hand-maintained CMDB rots immediately.
**Decision.** Seed CIs from the **Backstage catalog + live k8s** (services, DBs, namespaces, domains);
v1 = one-off seed, **ITSM-05** = ongoing sync.
**Consequences.** The CMDB reflects reality → useful for triage + DORA. Cost: a small sync job to build.

## ADR-006 — Alert→ticket: authenticated, idempotent webhook {#adr-006}
**Context.** Alerts should become incidents automatically (FR-5) without a duplicate storm or spoofing.
**Decision.** Alertmanager → an **authenticated webhook** (token/mTLS, source-IP netpol) → GLPI incident,
**idempotent on the alert fingerprint** (update, not duplicate); throttled.
**Consequences.** Real incidents auto-registered (DORA); T6/T9 mitigated.

## ADR-007 — Scope to service-management only {#adr-007}
**Context.** GLPI *can* do inventory, projects, dashboards — overlapping existing tools.
**Decision.** GLPI owns **service management** (incident/request/problem/change/SLA/CMDB/KB). **Metrics
stay in Prometheus/Grafana; project mgmt stays in Plane.** No feature turned on just because it exists.
**Consequences.** No tool-overlap sprawl; GLPI stays the service desk, not a second everything.

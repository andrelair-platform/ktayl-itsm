# Sprint Plan — ITSM v1 (GLPI service desk thin slice)

> **BMAD artefact — SPRINT PLAN + READINESS GATE.** Decomposes the thin slice into stories with ACs and
> states the readiness verdict. These refine the existing epics **ITSM-01…05**. **Status: DRAFT for review.**

## Slice goal

**Log in (SSO) → raise an incident/request → routed with an SLA → agent resolves it**, with a **minimal
CMDB** of real platform services and a **Prometheus alert auto-creating a ticket** — KPIs in Grafana.
GLPI is off-the-shelf → the work is **deploy + configure + integrate**, not build.

## Story breakdown

Each: epic · priority · estimate · acceptance criteria (happy + failure) · DoD.

### S001 — Deploy GLPI (wrapper chart + custom image)  · [ITSM-01] · P1 · 5
- **AC** ✓ custom image (CA trust + pinned ITIL plugins + PHP config) builds in CI (cosign+SBOM); ✓ GAP wrapper chart `services/ktayl-itsm/helm/` (GLPI + MariaDB + cron + ingress + cert + netpol) renders; ✓ dev up, reachable at the ingress host.
- **AC (fail)** ✗ DB creds via **ESO→Vault** (none in image/Git); ✗ default-deny netpol (GLPI↔MariaDB only).
- **DoD** dev Healthy; MariaDB backup wired to MinIO (DR-1).

### S002 — Authentik SSO + roles  · [ITSM-01] · P1 · 3
- **AC** ✓ OIDC login via Authentik + MFA; ✓ Authentik group → GLPI profile (agent vs requester); ✓ local admin sealed as break-glass.
- **AC (fail)** ✗ a requester cannot reach agent/admin functions (T2).
- **DoD** both roles demoed via SSO.

### S003 — Incident + request + SLA  · [ITSM-01] · P1 · 5
- **AC** ✓ raise an **incident** and a **request** from the self-service portal; ✓ one **SLA policy** (response+resolution by priority) with **escalation** on breach; ✓ full lifecycle to close.
- **AC (fail)** ✗ every ticket carries an SLA + an attributable, timestamped state log (AUD-1).
- **DoD** SLA breach escalation demoed; DORA incident fields present.

### S004 — Minimal CMDB (BYOD-scoped) + seed  · [ITSM-05] · P2 · 5
- **AC** ✓ CI types (App/Microservice/DB/Namespace/Domain/SaaS) with **owner** + dependency links; ✓ **seed ≥20 real platform services** from Backstage/k8s; ✓ a ticket can reference an affected CI.
- **AC (fail)** ✗ **no hardware/endpoint CIs** (BYOD boundary, ADR-003); ✗ CMDB is agent-only, not on the requester portal (T4).
- **DoD** CMDB reflects real services; triage "what depends on this?" works. (Ongoing auto-sync = later ITSM-05 increment.)

### S005 — Alert → auto-ticket  · [ITSM-04] · P2 · 5
- **AC** ✓ Alertmanager webhook → GLPI **incident**; ✓ **idempotent** on alert fingerprint (update, not duplicate); ✓ authenticated webhook + source netpol.
- **AC (fail)** ✗ if GLPI is down, alerting still fires elsewhere + webhook retries, **no lost alert** (AVL-2); ✗ an alert storm is throttled (T9).
- **DoD** a real alert auto-ticketed; re-fire = one incident.

### S006 — KPI dashboard (GLPI → Grafana)  · [ITSM-02] · P2 · 3
- **AC** ✓ glpi-exporter → Prometheus; ✓ Grafana panel: volume, **MTTR**, SLA-compliance, backlog; freshness ≤5 min.
- **DoD** dashboard live; numbers reconcile with GLPI.

### S007 — Self-service portal + KB  · [ITSM-01] · P3 · 3
- **AC** ✓ requester portal (raise/track tickets, browse KB); ✓ create a KB article + link it to a resolution.
- **DoD** a requester completes a request end-to-end via the portal.

> **Later (not v1):** **ITSM-03** IT helpdesk **AI assistant** (RAG over KB + Presidio PII-masking — Track-B
> AI-Act tier first); **ITSM-05** ongoing CMDB **auto-sync**; problem-management analytics.

**Slice total ≈ 29 pts.** Sequence: **S001→S002 (runs + SSO) → S003 (the desk) → S004 (CMDB) → S005 (alerts) → S006 (KPIs) → S007 (portal/KB).**

## Readiness gate

| Check | Verdict |
|---|---|
| Business need grounded | ✅ [Brief](./brief.md) — the one run-the-system gap (EA blueprint: ITSM/GLPI not deployed) |
| Product contract (PRD/NFR/compliance) | ✅ [PRD](./prd.md) + [NFR](./architecture/nfr-register.md) (DORA + GDPR) |
| Architecture + deployment + ADRs | ✅ [Solution Architecture](./architecture/solution-architecture.md) + [Deployment](./deployment-architecture.md) + [ADRs](./architecture/adr/000-index.md) |
| Threat model (holds PII + CMDB) | ✅ [Threat Model](./architecture/threat-model.md) — T1/T2 SSO, T3 ticket-PII, T6 webhook, T10 DB creds = gate blockers |
| Scope disciplined | ✅ service-management only (Plane=PM, Prometheus=metrics); BYOD CMDB; AI helpdesk deferred |
| Tool decision | ✅ GLPI (ADR-001), wrapper-chart deploy (ADR-002, decided) |
| Open (architecture-gate confirm, not a blocker) | ⚠️ own MariaDB in-wrapper vs stock chart (ADR-004) — confirm at the arch gate |

**Verdict: PASS (Path B — deploy-and-configure).** Off-the-shelf tool, deployment decided, integrations
are existing platform services. The only open item is a minor MariaDB-hosting confirmation (ADR-004),
resolvable at the architecture gate without blocking the start.

## After validation
1. Sync S001–S007 to board **#16** (`bmad/stories/itsm/` — refine the existing ITSM-01…05 epics into these stories).
2. Build `services/ktayl-itsm/helm/` + the custom image; stand up dev → SSO → incident/SLA → CMDB seed → alert→ticket → KPIs → portal.
3. Clear the Track-B gate (DORA incident-mgmt evidence; GDPR ticket-PII retention) before prod.

# PRD — ktayl ITSM (GLPI) (#16)

> **BMAD artefact — PRD.** The product contract: functional scope, NFRs, compliance. Right-sized for an
> **off-the-shelf** product (config, not code). **Status: DRAFT for review.**

## 1. Problem & goal

Give the ktayl IS a **service-management layer**: ticketing (incident/request), problem/change, SLAs, a
self-service portal + KB, and a **BYOD-scoped CMDB** — SSO-gated and wired to the existing platform.

## 2. In scope (v1) — ITIL v4 practices

| Practice | v1 scope |
|---|---|
| **Incident management** | log · categorise · prioritise · assign · resolve · close; SLA timers |
| **Service request** | request catalog (access, new app, how-to) · approval where needed |
| **Change enablement** | link to the existing `change-record` flow; GLPI holds change tickets for non-code ops changes |
| **SLM (SLAs)** | at least one SLA policy (response + resolution by priority) with escalation |
| **CMDB (config mgmt)** | **software/services/logical + cloud CIs** + ownership + basic dependency links |
| **Knowledge mgmt** | KB articles surfaced in the self-service portal |
| **Self-service portal** | requester login (SSO) → raise/track tickets, browse KB |

## 3. Out of scope (v1)
Hardware/endpoint/MDM assets (BYOD) · asset financials/lifecycle · advanced problem analytics · full
auto-discovery · AI helpdesk (ITSM-03, later increment) · project mgmt (Plane already covers it).

## 4. Functional requirements

- **FR-1** Authentik **OIDC SSO** login; GLPI groups/profiles mapped from Authentik claims (agent vs requester).
- **FR-2** Raise an **incident** and a **request** from the self-service portal; both get a ticket id + SLA.
- **FR-3** **SLA policy** (response/resolution by priority) with **escalation** on breach; visible on the ticket.
- **FR-4** **CMDB**: seed the platform's **real services** as CIs (apps/microservices/DBs/namespaces/domains/SaaS) with an **owner** and dependency links; a ticket can reference an affected CI.
- **FR-5** **Alert→ticket**: a Prometheus/Alertmanager alert **auto-creates/updates** an incident (dedup by alert fingerprint).
- **FR-6** **KPIs**: ticket volume, MTTR, SLA-compliance, backlog surface in **Grafana** (GLPI DB / API → Prometheus/exporter).
- **FR-7** **KB**: create/browse articles; link a resolution to a KB article.

## 5. Non-functional (see [NFR register](./architecture/nfr-register.md))
Availability (business-hours SLO), performance (portal responsive), security (SSO+RBAC, ticket PII,
least-privilege DB via ESO/Vault), backup/DR (MariaDB + attachments), observability, auditability.

## 6. Compliance (Track-B gate)
- **DORA** — incident management is a DORA control; GLPI is the **incident register + evidence** (timeline,
  classification, resolution). Major-incident fields align to DORA reporting.
- **GDPR** — tickets may contain **PII** (names, contact, free-text) → retention policy, access control,
  no PII to any LLM (the future AI helpdesk masks via Presidio).
- **ITIL v4** — practices above are the framework; this is BC01/BC03 governance + ops evidence.

## 7. Technology
**GLPI** (ITIL v4) + **MariaDB**, custom image from `ktayl-itsm` (CA trust + plugins + PHP config),
deployed as a **GAP wrapper chart** (`services/ktayl-itsm/helm/` in `minicloud-gitops`) — decided in
[deployment-architecture.md](./deployment-architecture.md). SSO = Authentik OIDC. Secrets = ESO→Vault.
Alert→ticket via Alertmanager webhook. KPIs via GLPI→Prometheus→Grafana.

## 8. Success metrics
100% of tickets carry an SLA; ≥1 real alert auto-ticketed; ≥20 platform services in the CMDB with owners;
MTTR + SLA-compliance visible in Grafana; portal reachable by any SSO user.

## 9. Dependencies
Authentik (SSO) · Vault/ESO (secrets) · Alertmanager (alert source) · Prometheus/Grafana (KPIs) ·
`minicloud-gitops` (deployment) · Backstage catalog (a CMDB seed source, ADR-005).

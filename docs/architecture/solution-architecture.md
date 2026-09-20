# Solution Architecture — ktayl ITSM (GLPI) (#16)

> **BMAD/SA artefact (index).** How ITSM fits the IS: processes, CMDB model, integrations, deployment.
> The *how-it-deploys* decision is already locked in [deployment-architecture.md](../deployment-architecture.md)
> (GAP wrapper chart). **Status: DRAFT for review.**

## 1. Overview

GLPI is the **service-management plane** over the existing platform: users raise tickets (SSO), agents
resolve them under SLAs, a **BYOD-scoped CMDB** records the real services, and the platform's
observability/eventing **feeds** it (alerts→tickets) and **reads** from it (KPIs→Grafana). Config, not code.

## 2. Context (C1)

```
  Employees / requesters ──SSO──►┌───────────────┐
  IT / ops agents ──────────────►│   GLPI (ITSM) │──► MariaDB (tickets · CMDB · KB)
  Service owners (CMDB) ────────►│  ITIL v4       │
                                 └───┬───────┬────┘
       Authentik (OIDC SSO) ────────┘       │
       Alertmanager ──webhook──► auto-ticket │  (FR-5)
       GLPI DB/API ──► exporter ──► Prometheus ──► Grafana (KPIs, FR-6)
       Backstage catalog / k8s ──► CMDB seed & sync (ADR-005, ITSM-05)
```

External systems (Authentik, Alertmanager, Prometheus/Grafana, Backstage, Vault) are **existing platform
services** — ITSM integrates, it doesn't rebuild them.

## 3. Container view (C2)

| Container | Tech | Responsibility |
|---|---|---|
| **GLPI web** | PHP/Apache (custom image) | ITIL practices, portal, CMDB, KB, REST API |
| **MariaDB** | StatefulSet + PVC | tickets, CMDB CIs, KB, config (source of truth) |
| **GLPI cron** | container/sidecar | SLA escalation, notifications, recurring tasks |
| **glpi-exporter** | small exporter/job | GLPI metrics → Prometheus (KPIs) |
| **alert-webhook** | GLPI receiver / thin adapter | Alertmanager → incident (dedup by fingerprint) |

Deployment shape (wrapper chart, dev+prod, ESO secrets, ingress+cert, netpol, Kargo) →
[deployment-architecture.md](../deployment-architecture.md).

## 4. CMDB model (BYOD-scoped — the deliberate shape)

CIs are **software/services/logical + cloud**, never a hardware fleet:

```
CI TYPES (v1):  Application · Microservice · Database · Namespace/Cluster · Domain/Endpoint · SaaS/External
RELATIONS:      depends-on · runs-in · owned-by · exposes · backs-up-to
EVERY CI:       owner (Authentik group/person) · environment (dev/prod) · criticality
```

Seeded from the **Backstage catalog + k8s** (ADR-005), so the CMDB reflects what actually runs — not a
hand-maintained spreadsheet. This directly supports incident triage ("what depends on this?") and DORA.

## 5. Key flows

1. **Ticket:** requester (SSO) → portal → incident/request → categorise + SLA timer → assign → resolve →
   (optional) link KB article + affected CI → close. Escalation fires on SLA breach.
2. **Alert→ticket:** Alertmanager webhook → GLPI creates/updates an incident, deduped by alert
   fingerprint, tagged to the affected CI where mappable (FR-5).
3. **KPIs:** glpi-exporter → Prometheus → Grafana dashboard (volume, MTTR, SLA-compliance, backlog).
4. **CMDB sync:** Backstage/k8s → CI upsert (ITSM-05, later increment; v1 = seed).

## 6. Integration principles
- **Identity:** Authentik OIDC is the only login; agent/requester by group claim (no local users but break-glass).
- **Secrets:** DB + app secrets via **ESO→Vault**, never in image/Git.
- **Least privilege:** GLPI DB user is app-scoped; network default-deny except MariaDB + the named integrations.
- **Don't rebuild:** metrics stay in Prometheus/Grafana; project mgmt stays in Plane; GLPI owns *service management* only.

## 7. Cross-references
[Brief](../brief.md) · [PRD](../prd.md) · [NFR](./nfr-register.md) · [Threat Model](./threat-model.md) ·
[ADR log](./adr/000-index.md) · [Deployment Architecture](../deployment-architecture.md) ·
[Sprint Plan](../itsm-v1-sprint-plan.md)

# NFR Register — ktayl ITSM (GLPI) (#16)

> **BMAD/SA artefact.** PRD NFRs made **measurable** (target + verification). **Status: DRAFT for review.**

## Performance
| ID | NFR | Target | Verify |
|---|---|---|---|
| PERF-1 | Self-service portal page load | p95 < 2s | k6 / RUM |
| PERF-2 | Ticket create/update | p95 < 1.5s | trace |
| PERF-3 | KPI freshness (GLPI→Grafana) | ≤ 5 min | exporter scrape interval |

## Availability & resilience
| ID | NFR | Target | Verify |
|---|---|---|---|
| AVL-1 | GLPI web (business hours) | 99.5% | uptime SLO |
| AVL-2 | Alert→ticket resilient | if GLPI is down, Alertmanager still alerts (email/Matrix); webhook retries; **no lost alert** | stop GLPI, fire alert, assert fallback + catch-up |
| AVL-3 | Idempotent alert→ticket | same alert fingerprint ⇒ one incident (update, not duplicate) | re-fire alert |

## Durability / DR
| ID | NFR | Target |
|---|---|---|
| DR-1 | MariaDB backed up | Longhorn snapshot + logical dump → MinIO; RPO ≤ 24h |
| DR-2 | Attachments/KB backed up | PVC in the backup set |
| DR-3 | Restore tested | documented restore runbook; RTO ≤ 2h |

## Security ([Threat Model](./threat-model.md))
| ID | NFR | Target |
|---|---|---|
| SEC-1 | AuthN/Z | Authentik OIDC + MFA; agent/requester by group; **local admin = break-glass only** |
| SEC-2 | DB creds | app-scoped MariaDB user via **ESO→Vault**; none in image/Git |
| SEC-3 | Ticket PII | GDPR retention + access control; **no PII to any LLM** (future AI helpdesk masks via Presidio) |
| SEC-4 | Network | default-deny; GLPI↔MariaDB + named integrations (Authentik, Alertmanager, exporter) only |
| SEC-5 | Supply chain | custom image cosign-signed + SBOM; Trivy CRITICAL gate; plugins pinned |
| SEC-6 | CMDB exposure | CMDB (topology + owners) is sensitive → agent-only, not requester-visible |

## Observability
| ID | NFR | Target |
|---|---|---|
| OBS-1 | Service KPIs | volume · MTTR · SLA-compliance · backlog in Grafana |
| OBS-2 | App health | GLPI/MariaDB up + cron running as Prometheus metrics + alert |

## Compliance / audit
| ID | NFR | Target |
|---|---|---|
| AUD-1 | Incident timeline | every ticket state change timestamped + attributable (DORA evidence) |
| AUD-2 | Major-incident fields | classification/impact/root-cause captured for DORA-reportable incidents |
| AUD-3 | Retention | ticket/PII retention policy enforced |

## Cost
| ID | NFR | Target |
|---|---|---|
| COST-1 | No new spend | GLPI + MariaDB = OSS on existing cluster; reuse platform substrate |

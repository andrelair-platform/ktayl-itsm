# Threat Model — ktayl ITSM (GLPI) (#16)

> **BMAD/SA artefact — STRIDE-lite.** Trust boundaries, top threats, mitigations. Reviewed at the
> security gate. **Status: DRAFT for review.**

## Trust boundaries
1. **Internet/Tailscale → ingress → GLPI** (SSO edge).
2. **GLPI → MariaDB** (app→datastore).
3. **Alertmanager → alert-webhook → GLPI** (inbound automation).
4. **GLPI DB/API → exporter → Prometheus** (outbound metrics).
5. **Backstage/k8s → CMDB** (inbound seed/sync).

## Top threats + mitigations
| # | STRIDE | Threat | Mitigation | NFR |
|---|---|---|---|---|
| T1 | Spoofing | Fake user / bypass SSO | Authentik OIDC + MFA only; local admin = break-glass, sealed | SEC-1 |
| T2 | Elevation | Requester gains agent/admin rights | group→profile mapping from Authentik; least-privilege profiles; review | SEC-1 |
| T3 | Info disclosure | **Ticket PII** leaks (free-text, contacts) | RBAC; requester sees own tickets only; retention; **no PII to LLM** | SEC-3 |
| T4 | Info disclosure | **CMDB** (topology + owners) exposed → recon aid | CMDB agent-only, not on the requester portal | SEC-6 |
| T5 | Tampering | Unauth CI/ticket modification | RBAC; audit trail; CMDB writes only via sync service creds | AUD-1 |
| T6 | Spoofing | Forged **alert→ticket** webhook | authenticated webhook (token/mTLS); source-IP netpol; **idempotent** (fingerprint) | AVL-3, SEC-4 |
| T7 | Tampering | Malicious/oversized **attachment** (ticket upload) | type/size limits; AV scan if enabled; store on PVC not web-root; Trivy on the image | SEC-5 |
| T8 | Repudiation | "I never changed that ticket" | immutable, attributable state-change log | AUD-1 |
| T9 | DoS | Portal flooded / alert storm creates ticket flood | rate-limit; alert-webhook **dedup + throttle**; SLA queue caps | AVL-2/3 |
| T10 | Elevation | Compromised **DB creds** | ESO→Vault, app-scoped user, rotate; netpol GLPI↔MariaDB only | SEC-2, SEC-4 |
| T11 | Supply chain | Malicious **GLPI plugin** | pin plugins; build from source in the custom image; cosign+SBOM+Trivy | SEC-5 |

## Security-gate blockers (must be true before prod)
- **T1/T2** SSO + least-privilege profiles enforced (no open local login).
- **T3** ticket PII access-controlled + retention set; **no PII path to any LLM**.
- **T6** alert→ticket webhook authenticated + idempotent.
- **T10** DB creds via ESO→Vault, default-deny netpol.

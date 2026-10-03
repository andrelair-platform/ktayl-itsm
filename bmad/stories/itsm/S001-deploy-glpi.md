---
id: S001
title: "Deploy GLPI (wrapper chart + custom image)"
status: Ready
type: Story
epic: itsm
milestone: "ITSM — ITSM v1"
estimate: 5
labels: [itsm, glpi, deploy]
priority: P1
assignee: AndreLiar
repo: andrelair-platform/ktayl-itsm
project: 16
initiative: IS Foundations
---

## Story
As a platform engineer, I want GLPI deployed via a GAP wrapper chart + a custom image, so the ITSM system of record runs on dev.

## Acceptance criteria
- [ ] Custom image (CA trust + pinned ITIL plugins + PHP config) builds in CI (cosign + SBOM).
- [ ] GAP wrapper chart `services/ktayl-itsm/helm/` (GLPI + MariaDB + cron + ingress + cert + netpol) renders.
- [ ] Dev up + reachable at the ingress host.
- [ ] DB creds via **ESO→Vault** (none in image/Git).
- [ ] Default-deny netpol (GLPI↔MariaDB only).

## DoD
Dev Healthy; MariaDB backup wired to MinIO (DR-1).

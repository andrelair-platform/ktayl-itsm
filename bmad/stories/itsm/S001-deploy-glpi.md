---
id: S001
title: "Deploy GLPI (wrapper chart + custom image)"
status: Done
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
- [x] Custom image (CA trust + pinned ITIL plugins + PHP config) builds in CI (cosign + SBOM).
- [x] GAP wrapper chart `services/ktayl-itsm/helm/` (GLPI + MariaDB + cron + ingress + cert + netpol) renders.
- [x] Dev up + reachable at the ingress host.
- [x] DB creds via **ESO→Vault** (none in image/Git).
- [x] Default-deny netpol (GLPI↔MariaDB only).

## DoD
Dev Healthy ✅ (itsm.10.0.0.200.nip.io HTTP 200, ArgoCD Synced/Healthy). MariaDB backup = prod-only (org rule: back up prod, not dev) → wired at prod promotion.

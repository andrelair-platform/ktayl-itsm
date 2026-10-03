---
id: S005
title: "Alert → auto-ticket"
status: Ready
type: Story
epic: itsm
milestone: "ITSM — ITSM v1"
estimate: 5
labels: [itsm, glpi, deploy]
priority: P2
assignee: AndreLiar
repo: andrelair-platform/ktayl-itsm
project: 16
initiative: IS Foundations
---

## Acceptance criteria
- [ ] Alertmanager webhook → GLPI **incident**; idempotent on alert fingerprint (update, not duplicate).
- [ ] Authenticated webhook + source netpol.
- [ ] If GLPI is down, alerting still fires + webhook retries (no lost alert, AVL-2); alert storm throttled (T9).

## DoD
A real alert auto-ticketed; re-fire = one incident.

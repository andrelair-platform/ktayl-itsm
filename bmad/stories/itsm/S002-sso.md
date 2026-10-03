---
id: S002
title: "Authentik SSO + roles"
status: Ready
type: Story
epic: itsm
milestone: "ITSM — ITSM v1"
estimate: 3
labels: [itsm, glpi, deploy]
priority: P1
assignee: AndreLiar
repo: andrelair-platform/ktayl-itsm
project: 16
initiative: IS Foundations
---

## Story
As an employee, I want to log into GLPI with Authentik SSO so access is identity-governed.

## Acceptance criteria
- [ ] OIDC login via Authentik + MFA.
- [ ] Authentik group → GLPI profile (agent vs requester).
- [ ] Local admin sealed as break-glass.
- [ ] A requester cannot reach agent/admin functions (T2).

## DoD
Both roles demoed via SSO.

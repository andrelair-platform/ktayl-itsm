---
id: S002
title: "Authentik SSO + roles"
status: Done
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
- [x] OIDC login via Authentik — native GLPI OIDC (`glpi-singlesignon` plugin), public route
  `itsm.devandre.sbs`, users auto-provision by email on first sign-in; redirect chain verified to the
  Authentik login ("Log in to continue to GLPI ITSM"). _(MFA is currently OFF platform-wide by owner
  decision — restorable via `minicloud-ops/scripts/authentik/mfa-toggle.sh on`.)_
- [~] Authentik group → GLPI profile — **deferred**: `glpi-singlesignon` v1.4.0 does **not** consume the
  OIDC `groups` claim for profile mapping (auto-provisions with the default profile). Owner
  pre-provisioned Super-Admin; claim-driven role mapping needs plugin v2.x (GLPI 11) or a GLPI rules
  layer → tracked as a follow-up (see S003/S007 grooming).
- [x] Local admin sealed as break-glass — the built-in `glpi` local account remains for break-glass; SSO
  is the primary path.
- [~] A requester cannot reach agent/admin functions (T2) — **deferred** with the group→profile AC above
  (needs claim-driven profiles + a requester test account).

## DoD
SSO login works end-to-end (public route + native OIDC + auto-provision + admin), org-site as-built doc
updated + build-checked. Role/profile mapping from the `groups` claim is a documented follow-up (plugin
limitation), not in-scope work left undone.

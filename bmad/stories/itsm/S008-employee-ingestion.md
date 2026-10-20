---
id: S008
title: "Employee ingestion via Authentik LDAP (requesters + daily sync)"
status: Done
type: Story
epic: itsm
milestone: "ITSM — ITSM v1"
estimate: 3
labels: [itsm, glpi, ldap, identity]
priority: P2
assignee: AndreLiar
repo: andrelair-platform/ktayl-itsm
project: 16
initiative: IS Foundations
---

## Story
As IT support, I want every employee to already exist in GLPI as a selectable **requester**, so we can
record and track *who requested what* — without waiting for each person to log in via SSO first.

## Acceptance criteria
- [x] GLPI LDAP directory configured against the shared Authentik LDAP outpost (`ktayl-ldap-outpost`,
  ns authentik) — the same outpost used for mail federation. Provisioned by the reusable
  `minicloud-ops/scripts/glpi/configure-ldap-directory.sh` (bind creds from Vault, `AuthLDAP::add()`
  run in-pod so `rootdn_passwd` is encrypted with the instance key).
- [x] Import filter = members of `Workplace Users` → all real employees, excluding service accounts /
  the `it` shared mailbox / `akadmin`. `sophie (100006)` added to the group to complete the roster.
- [x] All imported employees created as **Self-Service (requester)** profile (20 users).
- [x] OIDC↔LDAP de-duplication: identity keyed on **email** so an SSO login links to the imported
  account (no duplicate). Owner account reconciled in place → login `100001` + `kanmegnea@devandre.sbs`,
  Super-Admin retained.
- [x] Ongoing sync: daily `glpi-ldap-sync` CronJob (`30 2 * * *`) runs `glpi:ldap:synchronize_users`
  in the live pod via a least-privilege pods/exec SA (joiner/mover/leaver). Verified end-to-end on dev.

## DoD
LDAP directory live + 20 employees imported as requesters + daily sync CronJob proven running;
connectivity wired (outpost ingress admits itsm, GLPI egress to authentik, Cilium apiserver egress for
the sync pod); org-site as-built doc updated + build-checked. PRs: minicloud-gitops #1905/#1907/#1909,
minicloud-ops #15, minicloud-platform-docs #308.

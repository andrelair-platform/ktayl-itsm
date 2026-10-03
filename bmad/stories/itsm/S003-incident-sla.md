---
id: S003
title: "Incident + request + SLA"
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
As an agent, I want incidents/requests with SLA timers so the service desk runs to ITIL.

## Acceptance criteria
- [ ] Raise an **incident** and a **request** from the self-service portal.
- [ ] One **SLA policy** (response+resolution by priority) with **escalation** on breach.
- [ ] Full lifecycle to close; every ticket carries an SLA + attributable, timestamped state log (AUD-1).

## DoD
SLA breach escalation demoed; DORA incident fields present.

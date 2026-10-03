---
id: S004
title: "Minimal CMDB (BYOD-scoped) + seed"
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
- [ ] CI types (App/Microservice/DB/Namespace/Domain/SaaS) with **owner** + dependency links.
- [ ] Seed ≥20 real platform services from Backstage/k8s.
- [ ] A ticket can reference an affected CI.
- [ ] **No hardware/endpoint CIs** (BYOD boundary, ADR-003).

## DoD
CMDB reflects real services; "what depends on this?" triage works.

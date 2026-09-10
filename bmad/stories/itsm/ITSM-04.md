---
id: ITSM-04
title: "EPIC: Alerting → auto-ticket integration"
status: Ready
type: Epic
epic: itsm
milestone: "ITSM — ITSM v1"
estimate: 5
labels: [epic, itsm]
priority: P2
assignee: AndreLiar
repo: andrelair-platform/ktayl-itsm
project: 16
---

## Epic

Alerting → auto-ticket integration.

## Why
Alertmanager → GLPI auto-ticket so platform incidents become tracked ITSM tickets (overlaps OPS-5).

## Scope (epic-level)
- [ ] Alertmanager webhook → GLPI incident
- [ ] De-dup + severity mapping
- [ ] Close-the-loop on resolve

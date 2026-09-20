# Product Brief — ktayl ITSM (GLPI) (#16)

> **BMAD artefact — BRIEF.** Frames the business need. Right-sized: GLPI is **off-the-shelf**, so this is
> a **deploy-and-configure** product (Path B), not a custom build. **Status: DRAFT for review.**

## The need

The ktayl-solution IS has an **excellent run-the-platform toolchain** (Prometheus/Grafana/Loki/Tempo,
ArgoCD/Kargo, Vault, Velero, Falco/Gatekeeper/Trivy, Backstage) — but **no service-management layer**:
no place for a user to **raise a ticket**, no **incident / request / problem / change** workflow with
**SLAs**, and **no CMDB** (what services/apps exist, who owns them, what depends on what). Today the only
ITIL artefact is the automated **change-record** audit log (one issue per prod PR) — that covers *change*
but nothing else. The ops/support team is flying without a service desk.

## What GLPI gives us

**GLPI** (ITIL v4, open-source, self-hostable) delivers the missing layer: **service desk**
(incident/request), **problem & change**, **SLA/SLM**, a **self-service portal + knowledge base**, and a
**CMDB** — all SSO-gated via Authentik, wired to the platform's existing observability + eventing.

## Scope shaped by a decided boundary — **BYOD, no managed endpoints**

ktayl manages **no company hardware** (BYOD, browser-first — `project-governance.md` *IS scope
boundaries*). This **narrows and clarifies** the CMDB: it scopes to **software / services / logical +
cloud assets** (apps, microservices, namespaces, databases, domains, SaaS), **not** a hardware fleet.
That's a *cleaner* CMDB, not a lesser one — and it's the honest scope for this IS.

## v1 outcome (the thin slice)

A user can **log in (SSO) → raise an incident/request → it's routed with an SLA → an agent resolves it**,
a **minimal CMDB** holds the platform's real services, and a **Prometheus/Alertmanager alert
auto-creates a ticket**. KPIs surface in **Grafana**. Everything else (AI helpdesk, full CMDB auto-sync)
is a later increment.

## Explicitly out of scope (v1)

Hardware/endpoint/MDM asset management (BYOD boundary) · full problem-management analytics · asset
financial/lifecycle mgmt · a bespoke CMDB auto-discovery beyond the platform sync · the AI helpdesk
(ITSM-03, later).

## Users

IT/ops agents (resolve tickets) · every employee (self-service requester) · service owners (CMDB) ·
SRE (alert→ticket, KPIs) · compliance (DORA incident evidence).

## Why now

It's the **one operational gap** the run-the-system side has (flagged in the EA blueprint gap analysis
as *"Not deployed: ITSM/GLPI + CMDB"*), and the roadmap lists it as an **opportunistic quick win** —
low risk (off-the-shelf), high operational value, and it produces **DORA incident-management evidence**.

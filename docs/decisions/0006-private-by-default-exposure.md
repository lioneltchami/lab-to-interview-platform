# ADR 0006: Keep the Platform Private by Default

**Status:** Accepted
**Date:** 2026-08-28
**Decision owner:** Repository maintainer
**Review trigger:** Completion of routing, TLS, access-control, logging, threat-model, and policy validation in Phase 3.

## Context

The project needs to demonstrate platform delivery and operational evidence. It does not need a public endpoint during the foundational phases. Public exposure introduces additional responsibilities: domain ownership, TLS, identity, rate limits, attack surface, traffic logging, privacy review, incident response, and a clear reason for external access.

A public portfolio can link to sanitized documentation, code, diagrams, and recordings without connecting directly to a home-lab control plane or early application deployment.

## Decision

The Kubernetes API and all Phase 1 resources remain private. The initial local development service is reachable only through local development mechanisms. No domain, tunnel, public ingress, external DNS record, public registration, or public application endpoint will be created during Phase 1.

Phase 3 will decide whether the project benefits from an authenticated public demonstration endpoint. That decision must identify the audience, purpose, data exposure, authentication method, rate-limit strategy, network path, monitoring, response owner, and removal procedure.

## Decision criteria

| Criterion | Requirement | Validation |
|---|---|---|
| Purpose | Public access serves a named learner, contributor, or portfolio need. | Exposure ADR states the user journey and reason local access is insufficient. |
| Access control | The platform uses intentional identity and authorization controls where needed. | Access test proves intended roles and denied paths. |
| Transport security | The public route has a valid TLS configuration and documented certificate lifecycle. | TLS and renewal checks pass. |
| Network boundary | Public routing cannot reach the Kubernetes API, control-plane services, or unrelated home-network assets. | Network test and topology review pass. |
| Privacy | Logs, analytics, screenshots, and demo data contain no personal or private infrastructure information. | Public-release checklist passes. |
| Operations | The maintainer can observe, rate-limit, revoke, and disable the exposed service. | Runbook includes monitoring, incident response, and emergency shutdown. |

## Consequences

| Benefit | Cost or limitation | Mitigation |
|---|---|---|
| Phase 1 can focus on reproducible delivery rather than perimeter security. | Early demos remain local or recorded. | Publish sanitized walkthroughs and evidence instead of a live endpoint. |
| The Kubernetes API and home-network services avoid needless internet exposure. | A later public demo needs a dedicated design effort. | Create a specific exposure ADR and acceptance checklist in Phase 3. |
| The teaching material models responsible threat-aware sequencing. | Learners may want immediate public access. | Explain the reasons and provide a safe local-first lab path. |

## Security and privacy impact

No public resource exists in Phase 1. The maintainer must not put a home IP address, router screen, internal hostname, client certificate, tunnel token, or unredacted topology in public documentation. Any future public demo uses synthetic data and a separate sharing review.

## Validation plan

| Test or observation | Pass condition | Evidence location |
|---|---|---|
| Phase 1 check | No public route, tunnel configuration, external endpoint, or domain credential exists in tracked project files. | Repository review and secret scan. |
| Future route test | An authenticated user reaches only the intended application endpoint over TLS. | Phase 3 access and routing evidence. |
| Isolation test | The application route cannot access the cluster API or unrelated network systems. | Phase 3 network-policy/connectivity evidence. |
| Revocation drill | The maintainer can disable the public path and revoke access using the runbook. | Phase 3 operating record. |

## Alternatives considered

| Alternative | Strength | Reason not selected now |
|---|---|---|
| Public demo from the first release. | Gives easy remote viewing. | It expands attack surface and operational requirements before the platform establishes basic controls. |
| Public Kubernetes API. | Simplifies remote administration. | It creates a high-risk control-plane exposure that does not support the Phase 1 learning goal. |
| Permanent external tunnel for every service. | Fast access from any network. | It hides intended network boundaries and creates long-lived credential and route management needs. |

# Project Brief: Lab to Interview Platform

**Status:** Active Phase 1 baseline
**Owner:** Repository maintainer
**Review trigger:** At the end of each implementation phase or when the project’s audience, operating model, or privacy boundary changes.

## Purpose

Lab to Interview is an original home-lab platform that teaches and demonstrates practical platform-engineering work through one small application. The project will show a complete technical loop: documented architecture, version-controlled delivery, verified runtime behavior, security guardrails, telemetry, incident response, recovery, and clear communication.

The platform also creates the foundation for future teaching. The first teaching materials will use the project’s own tested runbooks, decision records, and evidence rather than generic tool tutorials.

## Primary audiences

| Audience | Need | How this project serves them |
|---|---|---|
| Hiring manager or technical interviewer | Fast evidence of systems thinking, delivery discipline, operational judgment, and communication. | A concise case study, linked technical artifacts, and demonstrations of deployment, incident response, and recovery. |
| Early-career platform or DevOps learner | A practical path from a small local build to an observable and recoverable system. | Clear prerequisites, narrow labs, verification steps, and reflection prompts. |
| Future community member | A safe example of how to create original technical portfolio evidence. | Templates, redaction guidance, evidence expectations, and an original capstone pattern. |
| Repository maintainer | A project that remains explainable and maintainable while it grows. | Explicit scope gates, decision records, tested runbooks, and a public/private data model. |

## Problem statement

Infrastructure learners often collect tools or self-hosted applications without a coherent project story. A hiring manager then sees a list of technologies rather than evidence of engineering judgment. Lab to Interview solves this by building one bounded platform in phases. Every major technology must support a specific system capability and leave evidence that someone can review.

## Project outcome

At completion, the repository will provide a sanitized, self-explanatory case study for a small GitOps-managed Kubernetes platform. It will deploy an original service, constrain workloads through security and policy controls, expose meaningful telemetry, record at least one controlled incident, and document a measured restore drill. The project will publish only claims supported by evidence.

> **Working promise:** Build a system you can run, explain, secure, observe, and recover.

## Scope

| Included | Excluded during the core five phases |
|---|---|
| A disposable local development cluster. | A public multi-tenant learning platform. |
| An original web/API sample service that begins with synthetic data. | A collection of unrelated personal media or home-automation applications. |
| A Git-based delivery source, CI checks, container images, and GitOps reconciliation. | A requirement that every service be self-hosted. |
| A durable physical cluster after the development path is proven. | High-availability claims before topology and failure behavior are validated. |
| Security controls, network policy tests, encrypted-secret design, and access documentation. | Committing real credentials, private network data, client data, or production kubeconfigs. |
| Observability, one controlled incident, backups, and a restore drill. | Unsupported “production-grade,” job-guarantee, or uptime claims. |
| Original technical lessons and interview material drawn from completed work. | Reproducing any community’s branding, course material, claims, source code, or member experience. |

## Phase gates

| Phase | Required outcome | Evidence required before moving forward |
|---|---|---|
| 1. Original foundation | Project documents, decision records, safe repository boundary, local development runbook, and repository checks. | Clean repository review, successful disposable-cluster cycle, and passing baseline checks. |
| 2. GitOps delivery | One original service builds, publishes, deploys, and rolls back in the development environment. | Pull request, CI record, reconciled resource status, and rollback record. |
| 3. Durable platform | A documented durable environment has separated overlays, safe access, routing, policy, and secret handling. | Topology diagram, policy test, TLS/access validation, and encryption/access evidence. |
| 4. Operations and recovery | The platform exposes useful telemetry, handles data, responds to a controlled incident, and completes a restore drill. | Dashboard, incident note, recovery contract, and dated restore report. |
| 5. Proof and teaching | The project is ready for technical review, interview demonstration, and an initial teaching pilot. | Case study, evidence index, recorded demonstrations, question bank, and lesson package. |

## Non-functional standards

| Standard | Requirement |
|---|---|
| Reproducibility | A documented clean environment can rebuild the phase outcome without relying on unrecorded manual steps. |
| Least privilege | Each service, user, token, and workflow receives only the access it needs. Exceptions are documented. |
| Observability | Each later production-shaped capability has a defined health signal and a response path. |
| Recoverability | Persistent state has a documented backup and a tested recovery procedure before a reliability claim is made. |
| Privacy | Artifacts are classified before sharing. Public materials contain no private infrastructure or personal data. |
| Explainability | Every major addition has a decision record and a short explanation suitable for an interviewer or learner. |
| Maintainability | Components have an owner, update method, deprecation plan, and review point. |

## Success measures

Measure only items that you can verify. These measures are project quality signals, not hiring or business guarantees.

| Measure | Evidence source | Target condition |
|---|---|---|
| Clean development rebuild | Runbook and terminal/test record. | A fresh local cluster reaches the Phase 1 baseline from documented steps. |
| Delivery traceability | Pull request, CI run, image digest, and reconciliation status. | A code or configuration change can be traced from commit to runtime state. |
| Policy behavior | Connectivity test and policy report. | The system demonstrates an expected allowed path and denied path. |
| Operational response | Dashboard, alert record, and incident review. | One controlled failure is detected, understood, and remediated through documented steps. |
| Recovery evidence | Restore report and validation output. | One documented restore reaches the expected state within a measured time. |
| Technical narrative | Case study and recorded demonstration. | A reviewer can understand the goal, system, trade-offs, and evidence in ten minutes. |

## Current assumptions and open decisions

| Topic | Current baseline | Decision owner | Review point |
|---|---|---|---|
| Public Git source | GitHub will be the canonical source while the repository is private during Phase 1. | Repository maintainer. | Before any public release. |
| Local development | Docker Desktop and Kind on an ARM-based macOS computer. | Repository maintainer. | After the first clean create-and-delete cycle. |
| Durable node operating system | Talos is the leading candidate. | Repository maintainer. | Before Phase 3 hardware configuration. |
| First service | A status-and-incident tracker with synthetic data. | Repository maintainer. | Before implementation begins in Phase 2. |
| Secrets | A documented encrypted-secret design; implementation choice remains open until cloud and learning goals are confirmed. | Repository maintainer. | Before any secret resource is created. |
| Public exposure | No application service is public during Phase 1. | Repository maintainer. | After threat model, access, and TLS design are complete. |
| Forgejo | Optional later platform-service elective, not a core dependency. | Repository maintainer. | After an incident and restore drill establish the core platform. |

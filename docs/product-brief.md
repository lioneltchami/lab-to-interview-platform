# Product Brief: Signalboard

**Status:** Phase 1 definition, implementation deferred to Phase 2
**Working product name:** Signalboard
**Purpose:** A small original service used to exercise the Lab to Interview platform without introducing unrelated product complexity.

## Product statement

Signalboard is a lightweight service-status and incident tracker. A user can view the current status of a small set of synthetic services, review a recent incident, and create or update a simulated incident through an authenticated administrative action in later phases.

Signalboard exists to provide a realistic platform workload. It is not intended to become a commercial product or a complete monitoring system. Its design deliberately creates an HTTP request path, health endpoints, configuration, structured logs, metrics, a background-work candidate, a database migration, a controlled failure scenario, and a recovery target.

## User roles

| Role | First release capability | Later capability |
|---|---|---|
| Visitor | View synthetic service status and a recent incident timeline. | View public or authorized status according to the selected exposure model. |
| Operator | Not implemented in the first release. | Create an incident, change component state, add a timeline note, and resolve an incident. |
| Platform maintainer | Deploy, configure, observe, secure, and recover the service. | Demonstrate the full operational loop through linked evidence. |
| Learner | Use the project as a reproducible example and complete a tailored version. | Submit an evidence ledger, incident review, and technical explanation. |

## Minimum viable release

The first release must stay stateless and use deterministic synthetic data. A user should load one page and receive a simple status view from an API. The API should expose a version endpoint, a readiness endpoint, a liveness endpoint, and structured request logs. Tests should cover the status response and one expected error behavior.

| Capability | Include in first release | Defer |
|---|---|---|
| Web interface | A simple, responsive status overview. | Complex navigation, theming, real-time updates, dashboards, or member features. |
| API | Read-only status and incident endpoints with an explicit version response. | Broad public APIs, integrations, rate-limit systems, and user-facing tokens. |
| Data | Seeded synthetic records in application memory or a fixture file. | PostgreSQL, migrations, private user data, and external telemetry sources. |
| Authentication | None for the read-only development release. | Admin authentication, authorization, and audit events. |
| Operations | Liveness, readiness, startup behavior, structured logs, basic metrics. | Full tracing, multi-region reliability, autoscaling, or public SLO commitments. |
| Deployment | One replica in the disposable development cluster. | Staging/production promotion and durable physical deployment. |

## Technical boundaries

| Boundary | Design requirement |
|---|---|
| Originality | The user interface, API, domain model, tests, documentation, and deployment configuration must be original work. |
| Data | Use synthetic, non-personal service names and incident data only. Do not ingest real operational events, user accounts, or private infrastructure details. |
| Security | The first container must run without root privileges and require no host access, privileged capability, host networking, or host-mounted files. |
| Configuration | Inject ordinary configuration through environment variables or ConfigMaps later. Keep secrets out of the first release. |
| Health | Separate liveness from readiness. The application must state its version and provide a clear unhealthy behavior for testing. |
| Observability | Emit structured logs with a correlation field and expose a minimal metrics endpoint in a later Phase 2 increment. |
| Recovery | Add persistent data only in Phase 4, after the recovery contract and test plan exist. |
| Public exposure | Keep the service private during Phase 1. Any later public demo must use a reviewed access and redaction design. |

## Phase-by-phase service evolution

| Platform phase | Signalboard capability | Platform behavior being exercised | Evidence artifact |
|---|---|---|---|
| 1. Foundation | Product brief and acceptance tests only. | Scope control and design clarity. | This brief and the first architecture decision record. |
| 2. Delivery | Stateless web/API service with synthetic data. | Container build, CI, GitOps delivery, health behavior, and rollback. | Pull request, build result, deployed digest, and rollback record. |
| 3. Durable platform | Service uses intended routing, configuration, encrypted secret boundary if needed, and network isolation. | TLS, least privilege, policy, and network controls. | Connectivity test, policy report, and access design. |
| 4. Operations | Service uses PostgreSQL, emits telemetry, triggers a controlled incident, and passes a restore drill. | SLOs, logs, metrics, incident response, data backup, and recovery. | Dashboard, incident review, recovery contract, and restore report. |
| 5. Evidence | Service supports a concise live or recorded demonstration. | Clear technical communication and teaching. | Case study, demo script, and interview question bank. |

## Acceptance criteria for the Phase 2 first release

| Criterion | Pass condition |
|---|---|
| Build | The application builds into an ARM-compatible OCI image with a pinned base image. |
| Test | Automated tests pass for the primary status request and one known error behavior. |
| Health | The service exposes distinct endpoints for liveness, readiness, and version information. |
| Runtime identity | The application returns a build or version identifier that matches the deployed release evidence. |
| Security | The deployment requires no elevated container privileges and runs as a non-root user. |
| Delivery | A pull request produces validation evidence; a merged, approved revision becomes the declared development deployment. |
| Rollback | Reverting to a known-good Git revision restores the earlier service version and health behavior. |
| Documentation | The README explains the purpose, request path, configuration surface, and verification steps. |

## Non-goals

Signalboard will not become an all-in-one observability platform, a commercial status-page service, an incident-management replacement, a social network, or a hidden vehicle for personal data. Each deferred capability needs its own decision record and evidence requirement before implementation.

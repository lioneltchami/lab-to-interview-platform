# Lab to Interview Platform

**An original, evidence-led home-lab platform for learning, teaching, and explaining practical platform engineering.**

Lab to Interview starts with one question: can you build a system that you can **run, explain, secure, observe, and recover**? The project turns that question into a small, reproducible platform with a clear source of truth, tested delivery path, documented trade-offs, and practical evidence.

The work begins with a disposable local development environment and a deliberately small sample service. It will later grow into a GitOps-managed Kubernetes platform with policy controls, telemetry, a recovery drill, teaching assets, and an interview-ready case study. The project does not claim high availability, production readiness, or job outcomes before the corresponding evidence exists.

## Project principles

| Principle | Meaning in this repository |
|---|---|
| **Original work** | This repository contains original code, configuration, diagrams, documentation, and teaching assets. It uses external projects as cited references and never as copied identity or undisclosed source material. |
| **Evidence before claims** | A design decision, deployment, policy, incident, or recovery claim should link to a test, report, runbook, or versioned artifact. |
| **Small, verifiable steps** | Each phase produces a runnable or reviewable outcome before the next platform capability is added. |
| **Safety by design** | Secrets, home-network details, credentials, customer data, and the archived reference implementation remain outside public project history. |
| **Teaching from practice** | Lessons are written from work that has been performed, validated, and recorded. |

## Current phase: Phase 1 — original foundation

Phase 1 establishes the project identity, documentation standards, Git governance, a safe reference-archive boundary, a disposable development path, and automated repository checks. The initial repository remains private while its public/private sharing model is reviewed.

| In progress | Phase 1 outcome |
|---|---|
| Project brief | Defines the technical, teaching, and interview goals. |
| Sample-service brief | Constrains the first application to a small, synthetic-data workload. |
| Decision records | Captures why the platform uses its chosen patterns and which options were rejected. |
| Evidence index | Lists the artifacts that will support each technical claim. |
| Development runbook | Documents a disposable local Kubernetes baseline. |
| CI baseline | Validates repository hygiene, rendered configuration, and secret boundaries before merge. |

## Repository map

```text
.
├── apps/                 # Application deployment bases and overlays
├── clusters/              # Environment-specific cluster configuration
├── docs/
│   ├── architecture/      # Diagrams and design narratives
│   ├── decisions/         # Architecture Decision Records (ADRs)
│   ├── evidence/          # Evidence index and verified outcomes
│   ├── runbooks/          # Reproducible operating procedures
│   ├── security/          # Threat model, data classification, access model
│   └── teaching/          # Original lesson plans and exercises
├── infrastructure/        # Platform services and their configuration
├── platform-app/          # Original sample application source code
├── scripts/               # Safe, reviewed developer automation
└── tests/                 # Manifest, policy, and recovery validation fixtures
```

## Public/private boundary

Do not commit or publish credentials, private keys, API tokens, service-account credentials, kubeconfigs, Talos machine secrets, local IP ranges, home addresses, router configuration, unredacted screenshots, production logs, or user data. The supplied historical homelab archive remains a private reference and is excluded from this repository.

Any public release must pass the sharing checklist in [`docs/security/data-classification.md`](docs/security/data-classification.md). A repository maintainer must approve the release after reviewing the proposed visibility, content, and evidence claims.

## Starting point

Read these documents in order before contributing to platform work:

1. [`docs/project-brief.md`](docs/project-brief.md)
2. [`docs/product-brief.md`](docs/product-brief.md)
3. [`docs/decisions/0001-reference-archive-boundary.md`](docs/decisions/0001-reference-archive-boundary.md)
4. [`docs/runbooks/dev-bootstrap.md`](docs/runbooks/dev-bootstrap.md)
5. [`docs/evidence/index.md`](docs/evidence/index.md)

## Contribution approach

Use short-lived branches and pull requests. Each change should state its purpose, verification evidence, documentation impact, and security review outcome. The repository contains templates for pull requests and issues in [`.github/`](.github/).

A Phase 1 contribution should improve the foundation. It should not add exposed services, real secrets, personal workloads, or unreviewed infrastructure complexity.

## Status and next decision

The initial development baseline uses a local ARM-compatible Docker environment and Kind. The next Phase 1 milestone is to validate a clean create-and-delete cycle, then add the first repository checks. The sample service remains intentionally undefined in implementation until its brief and acceptance criteria are approved.

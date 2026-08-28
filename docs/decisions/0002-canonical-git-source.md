# ADR 0002: Use GitHub as the Canonical Source During the Core Build

**Status:** Accepted
**Date:** 2026-08-28
**Decision owner:** Repository maintainer
**Review trigger:** Completion of the verified restore drill, a documented private-collaboration need, or a deliberate advanced self-hosted-forge module.

## Context

Lab to Interview needs a simple source of truth for code, documentation, manifests, review, and evidence. The source must support a low-friction public contribution model when the repository is ready to be shared. The platform will later reconcile declared state from Git through a GitOps controller.

The project evaluated self-hosting a software forge as a later learning module. A self-hosted forge adds its own database, storage, identity, upgrade, backup, reverse-proxy, and runner-security responsibilities. Those responsibilities have value only after the core platform can demonstrate safe operations.

## Decision

GitHub is the canonical Git source for the core five-phase build. The repository starts private. The maintainer will decide when selected material becomes public after passing the data-classification and sharing review.

The GitOps controller will later reconcile from the canonical repository. No second forge may become a writable source for the same public deployment state during the core build. A self-hosted Forgejo instance remains an optional advanced workload after the core platform has passed an incident and restore drill.

## Decision criteria

| Criterion | Requirement | Validation |
|---|---|---|
| Source authority | One service has final authority for public code and deployment state. | Remote configuration, contribution instructions, and later Flux source agree. |
| Contributor experience | A new contributor can access public work without a second self-hosted account. | Public-release review includes a new-reader walkthrough. |
| Delivery traceability | A change can be followed from pull request to later deployment evidence. | Pull request, CI result, image reference, and reconciliation record link to one commit. |
| Operational focus | Phase 1–2 effort remains on the original platform, not forge administration. | No self-hosted forge blocks foundational milestones. |

## Consequences

| Benefit | Cost or limitation | Mitigation |
|---|---|---|
| The project has one clear public source of truth. | The project does not practice self-hosted forge operations in the core path. | Treat a private forge as a later elective only when it serves an explicit learning goal. |
| Contributors can use a familiar public collaboration model. | The project depends on a hosted source-control service for the public path. | Keep an independent local clone and create a recovery plan before making reliability claims. |
| The first CI configuration can remain small and hosted. | Some enterprise environments use different forges. | Keep Git workflows, manifests, and automation portable where practical. |

## Security and privacy impact

The repository remains private until the maintainer completes a public-sharing review. Contributors must not add real secrets, private infrastructure data, personal information, or the historical archive. Repository access follows least privilege and the pull-request template requires a secret and privacy review.

## Validation plan

| Test or observation | Pass condition | Evidence location |
|---|---|---|
| Remote check | The repository has a single canonical `origin` remote. | `git remote -v` captured in setup notes. |
| Contribution check | Pull-request template identifies source authority and review expectations. | `.github/pull_request_template.md`. |
| Visibility check | Public-release checklist classifies every proposed public artifact. | `docs/security/data-classification.md`. |
| Future GitOps check | A later GitOps source points only to this canonical repository. | `clusters/<environment>/` configuration. |

## Alternatives considered

| Alternative | Strength | Reason not selected now |
|---|---|---|
| Self-host Forgejo as the only source from Phase 1. | Provides direct forge-administration practice. | It adds a platform service before the lab can reliably host, secure, monitor, and recover it. |
| Use two writable sources. | Offers multiple collaboration locations. | It creates source-authority ambiguity and risks inconsistent deployment state. |
| Keep all work only on a local computer. | Avoids hosted-service dependency. | It weakens collaboration, review traceability, and public portfolio access. |

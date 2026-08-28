# ADR 0003: Use Flux for GitOps Delivery

**Status:** Accepted for Phase 2 implementation
**Date:** 2026-08-28
**Decision owner:** Repository maintainer
**Review trigger:** A proven Phase 2 delivery loop, an integration requirement Flux cannot meet, or a targeted role that requires a different GitOps platform.

## Context

The project needs a delivery pattern that makes intended cluster state reviewable, repeatable, and separate from ad hoc runtime changes. The historical reference review identified environment overlays and ordered reconciliation as useful architectural patterns. Lab to Interview will implement them as original configuration after it proves a local development environment.

The GitOps controller must support a repository-based source of truth, staged environment overlays, clear reconciliation status, image promotion controls, and an understandable rollback path.

## Decision

Lab to Interview will use Flux as the GitOps controller beginning in Phase 2. The initial scope is a disposable development cluster and one application. The repository will organize cluster declarations, infrastructure, application bases, and environment overlays so that platform controllers reconcile before dependent workloads.

The project will not bootstrap Flux in Phase 1. Phase 1 prepares the local environment, repository structure, checks, and runbook. The maintainer will first validate all generated configuration locally before Flux is allowed to reconcile it.

## Decision criteria

| Criterion | Requirement | Validation |
|---|---|---|
| Source of truth | Declared state comes from the canonical repository. | Flux source configuration identifies the canonical repository and a pinned revision strategy. |
| Reproducibility | A clean development cluster can reconcile the intended baseline. | Bootstrap runbook reaches a healthy reconciliation state. |
| Environment separation | Development and later staging/production declarations remain explicit. | Kustomize rendering for each environment shows intentional differences only. |
| Change control | A rollback occurs through a documented Git revision or image reference. | Phase 2 rollback exercise has a dated evidence record. |
| Explainability | A learner can map repository folders to the deployed system. | Repository map and teaching note match runtime status. |

## Consequences

| Benefit | Cost or limitation | Mitigation |
|---|---|---|
| Git records intended deployment state and history. | The maintainer must learn controller reconciliation and Kustomize layering. | Start with one workload and a disposable cluster. |
| Environment configuration can remain readable and reviewable. | Folder structure can become over-engineered. | Add directories only when a defined environment or dependency requires them. |
| Rollbacks use an auditable source change. | Reconciliation delays can make debugging feel indirect. | Record reconciliation status and add clear runbook checks. |

## Security and privacy impact

Flux access credentials and encrypted secrets must not be committed in plain text. The controller receives only the repository permissions required for the declared source. The project will record the bootstrap credential lifecycle before it creates the first cluster connection.

## Validation plan

| Test or observation | Pass condition | Evidence location |
|---|---|---|
| Local render | All Phase 2 Kustomize configurations render without error. | CI validation output. |
| Bootstrap | A disposable cluster reports a healthy Flux source and Kustomization. | `docs/evidence/phase-2-delivery.md`. |
| Drift response | A documented configuration change reaches runtime through reconciliation. | Pull request and controller status. |
| Rollback | Reverting the declared revision restores the prior application state. | Rollback runbook and test record. |

## Alternatives considered

| Alternative | Strength | Reason not selected now |
|---|---|---|
| Manual imperative deployment. | Fast for one-off local experimentation. | It does not create a reviewable source of truth or repeatable delivery story. |
| Argo CD. | Strong ecosystem and familiar interface. | Flux fits the intended lightweight monorepo pattern and keeps the first GitOps lesson narrow. |
| Delay GitOps until the physical lab. | Avoids local controller setup. | It makes physical hardware the first point of failure and postpones delivery learning. |

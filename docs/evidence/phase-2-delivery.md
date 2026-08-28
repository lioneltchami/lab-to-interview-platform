# Phase 2 Delivery and Rollback Evidence

**Status:** Verified local-development evidence
**Evidence date:** 2026-08-28 00:05 MDT
**Environment:** Disposable local Kind cluster on an ARM-based macOS workstation
**Classification:** Public after review
**Author:** Manus AI

## Scope and pass condition

Phase 2 proves a bounded delivery loop for the original, stateless Signalboard workload. The pass condition is not merely that Kubernetes objects exist. A reviewed Git commit must be fetched from the canonical public repository, Flux must reconcile the declared Kustomize overlay, the container image already loaded into the named local Kind cluster must roll out safely, and a local-only verification must confirm the expected API version, workload health, structured request logs, and lack of an external service route.

The Phase 2 GitOps design uses a Flux `GitRepository` and dependent `Kustomization` resources. Flux documents the GitRepository as the source artifact for a repository and documents Kustomization as the controller that fetches, builds, validates, and applies Kustomize configuration. [1] [2]

## Platform record

| Item | Verified value |
|---|---|
| Canonical source | `https://github.com/lioneltchami/lab-to-interview-platform`, branch `main` |
| Application | Signalboard, a synthetic read-only service-status and incident tracker |
| Runtime | Node.js 22.23.1; non-root `node` image user |
| Development deployment image | Local Kind-loaded `signalboard` image tags only; no registry publication was used |
| Kubernetes | Kind server `v1.37.0` |
| Flux distribution | Flux `v2.9.4`; source-controller and kustomize-controller reconciled successfully |
| Service exposure | `ClusterIP` on port 80 with no external IP and no Ingress in the Signalboard namespace |
| Data boundary | Deterministic synthetic status and incident data; no credentials, personal data, or real incident records |

## Initial application and GitOps verification

| Control | Evidence | Result |
|---|---|---|
| Native application tests | Five Node.js tests covered status response, live and ready health endpoints, version endpoint, root interface, method and missing-route error behavior, security headers, and structured-log query exclusion. | Passed locally. |
| Local container test | The `signalboard:0.1.0-dev` image built for ARM64, ran as `node`, and returned healthy readiness, version, and interface responses. | Passed locally. |
| Manifest render | `apps/overlays/dev` rendered a Namespace, ServiceAccount, ConfigMap, Deployment, and ClusterIP Service. The development root rendered Flux controllers, GitRepository, and Kustomization resources. | Passed locally and in remote Phase 2 validation. |
| Deployment hardening | The workload declared non-root execution, no automatic service-account token, no privilege escalation, all Linux capabilities dropped, a read-only root filesystem, resource requests and limits, startup probe, liveness probe, and readiness probe. | Rendered and deployed. |
| Flux bootstrap | The explicit bootstrap procedure first applied generated controller resources, waited for GitRepository and Kustomization CRDs to be established, waited for controller rollouts, then applied the sync resources. | Passed after correcting the initial CRD-ordering defect. |
| Git reconciliation | Flux fetched and applied `main@sha1:d69bb1853f229e48fa8a602b1f082f4e5310abfb` for the first deployment. | Passed. |
| Internal service verification | The Phase 2 verifier waited for both Flux Kustomizations and the Deployment, confirmed the ClusterIP service and no Ingress, accessed readiness and version through a temporary local port forward, and found a structured request log. | Passed. |

## Source-delivery exercise

The first tag-only exercise promoted the declared development tag from `0.1.0-dev` to `0.1.1-dev`, then reverted it. That exercise confirmed the version path, but it did not change application source. The stronger source-delivery exercise used the commit below.

| Field | Record |
|---|---|
| Delivery commit | [`7338ff5`](https://github.com/lioneltchami/lab-to-interview-platform/commit/7338ff50067a575e1a15231cac22f9da4e0c0c87) — `feat: deliver signalboard release marker through gitops` |
| Source change | Added the deterministic `release.marker: phase-two-foundation` field to `GET /api/v1/status` and added a corresponding test. |
| Declared image/version | `signalboard:0.1.2-dev` and `APP_VERSION=0.1.2-dev` in the development overlay. |
| Local image control | The updated source was built as `signalboard:0.1.2-dev` and loaded into `lab-to-interview-dev` before reconciliation. |
| Flux source revision | `main@sha1:7338ff50067a575e1a15231cac22f9da4e0c0c87` |
| Deployment proof | Flux reported the Signalboard Kustomization as applied at the same revision. The verifier confirmed the `0.1.2-dev` version and the `phase-two-foundation` source marker through the internal ClusterIP service. |
| Automated checks | [Phase 2 validation passed](https://github.com/lioneltchami/lab-to-interview-platform/actions/runs/33146679612) and [repository validation passed](https://github.com/lioneltchami/lab-to-interview-platform/actions/runs/33146679614). |

## Git-based rollback exercise

| Field | Record |
|---|---|
| Reverted source commit | `7338ff50067a575e1a15231cac22f9da4e0c0c87` |
| Rollback commit | [`bd0377a`](https://github.com/lioneltchami/lab-to-interview-platform/commit/bd0377ae2039c6caab426efbc60f330bb935cf5e) — `Revert "feat: deliver signalboard release marker through gitops"` |
| Rollback action | Created a Git revert, pushed it to `main`, reconciled the Flux GitRepository, reconciled the Signalboard Kustomization, and ran the full delivery verifier. No live Deployment or ConfigMap patch was used. |
| Flux source and applied revision | `main@sha1:bd0377ae2039c6caab426efbc60f330bb935cf5e` |
| Recovered state | Deployment available `1/1`; ClusterIP service retained with no external IP; `/health/ready` returned ready; `/api/v1/version` returned `0.1.0-dev`; structured request logs were present. |
| Measured elapsed time | 15 seconds from initiating the Git revert command through successful Flux reconciliation and full verification. |
| Automated checks | [Phase 2 validation passed](https://github.com/lioneltchami/lab-to-interview-platform/actions/runs/33146746350) and [repository validation passed](https://github.com/lioneltchami/lab-to-interview-platform/actions/runs/33146746313). |

## Final verified state

At evidence capture, `main` was clean at `bd0377ae2039c6caab426efbc60f330bb935cf5e`. The Flux GitRepository and both Flux Kustomizations were `Ready=True` at that revision. Signalboard had one desired, current, and available replica. Its Kubernetes Service was a `ClusterIP` with no external address. The final declared application version was `0.1.0-dev`, the known-safe post-rollback baseline.

## Corrective findings

| Finding | Resolution | Prevention carried forward |
|---|---|---|
| The first bootstrap attempt applied Flux custom resources before their CRDs had become established. | The bootstrap script now applies controller resources first, waits for both CRDs, waits for controller rollouts, and only then applies GitRepository and Kustomization resources. | Preserve the ordered bootstrap and test it on every fresh cluster recreation. |
| The first manifest validator hard-coded `0.1.0-dev`, which would have rejected a legitimate declared version update. | The validator now reads the image tag from the development overlay and permits an explicit expected-version override. | Keep manifest tests derived from declared state rather than a stale literal. |
| The first log assertion used a pipe that could fail under `pipefail` after `grep -q` closed early. | The verifier captures the log output before its direct shell match. | Avoid early-closing pipeline assertions in strict shell scripts. |

## Limits of this evidence

This evidence proves a single stateless, local, manually image-loaded workload and a declarative Git rollback. It does **not** prove continuous image publishing, a remote registry, private-source authentication, durable hardware, high availability, database migration safety, backup and restore, external ingress, identity management, network policy for Signalboard, production service-level objectives, or incident alerting. Those remain explicitly out of scope until their own phases and evidence records exist.

## Evidence-index update

| Evidence ID | Status | Evidence location |
|---|---|---|
| E-005 — Git change reaches development cluster | Verified | This record; source-delivery commit `7338ff5`; source-delivery workflow runs; Flux status; endpoint verification. |
| E-006 — deployment can roll back | Verified | This record; Git revert `bd0377a`; Flux status; final endpoint verification; 15-second measured exercise. |

## References

[1]: https://fluxcd.io/flux/components/source/gitrepositories/ "Flux — Git Repositories"
[2]: https://fluxcd.io/flux/components/kustomize/kustomizations/ "Flux — Kustomization"

# Phase 1 Evidence: Disposable Development Baseline

**Evidence ID:** E-003
**Status:** Verified — creation, teardown, clean rebuild, and repository-validation paths completed.
**Environment classification:** Internal project
**Date:** 2026-08-27

## Objective

Verify that the local workstation can create a disposable Kubernetes development cluster without physical lab hardware, public exposure, live application secrets, or undocumented setup actions.

## Tooling observed

| Component | Observed version or state |
|---|---|
| Workstation architecture | ARM-based macOS environment. |
| Container runtime | Docker Desktop, server version `29.4.0`. |
| Cluster tool | Kind `v0.33.0` for `darwin/arm64`. |
| Kubernetes client | `kubectl` client `v1.33.9` with embedded Kustomize `v5.6.0`. |
| Disposable cluster | `lab-to-interview-dev`. |
| Node image | Kind Kubernetes node `v1.37.0`. |

## Creation result

The documented Kind creation command completed successfully. The tool created one local control-plane node, installed its default CNI and storage class, waited for readiness, and selected the `kind-lab-to-interview-dev` context.

## Health verification

| Check | Expected result | Observed result | Outcome |
|---|---|---|---|
| Cluster information | The local Kubernetes control plane responds through the project context. | The project context returned control-plane and CoreDNS information. | Pass |
| Node readiness | One local control-plane node becomes `Ready`. | One control-plane node reported `Ready`. | Pass |
| Core system workloads | Kubernetes system workloads become healthy. | CoreDNS, etcd, API server, controller manager, proxy, scheduler, and local storage workloads reported running and ready. | Pass |
| Public exposure | No public route or project application endpoint exists. | The exercise created a local disposable cluster only. | Pass |
| Secrets | No project secret or credential was introduced. | The exercise used no project-managed secret. | Pass |

## Remaining validation

| Check | Required result | Status |
|---|---|---|
| Teardown | Delete only `lab-to-interview-dev` and confirm it no longer appears in the Kind cluster list. | Verified — Kind reported no remaining project cluster. |
| Rebuild | Create the same named cluster again from the runbook and confirm node and system-pod readiness. | Verified — the second cluster creation completed and the node plus all system pods reached their expected healthy states. |
| Runbook review | Compare observed steps and tool versions with `docs/runbooks/dev-bootstrap.md`. | Verified — the recorded environment, creation command, health checks, and teardown path match the runbook. |
| Repository validation | Run the controlled negative credential test and a clean repository validation. | Verified — the validator rejected a harmless credential-shaped probe and passed after cleanup. |

## Lifecycle result

The first cluster created successfully, passed its health checks, deleted cleanly, and then recreated successfully with the same documented command. The corrected health check confirmed that the replacement node was `Ready` and each system workload reported `Running` or `Completed`. The repository validator also passed its deliberate negative credential test and then passed the clean repository baseline.

## Limitations

This evidence proves a disposable local development baseline only. It does not prove Flux bootstrap, application delivery, ingress, public access, policy enforcement, persistence, high availability, security hardening, backup, or recovery.

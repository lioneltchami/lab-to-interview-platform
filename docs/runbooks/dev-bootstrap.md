# Runbook: Disposable Local Development Cluster

**Status:** Phase 1 baseline
**Environment:** ARM-based macOS workstation, Docker Desktop, Kind, and `kubectl`
**Purpose:** Create and remove a local Kubernetes environment without using durable hardware, public endpoints, live secrets, or unrecorded manual configuration.

## Scope and safety boundary

This runbook creates a disposable development cluster named `lab-to-interview-dev` on the local workstation. It is not a durable environment, a public service, or an HA cluster. It must not contain real secrets, personal data, production kubeconfigs, home-network settings, or externally reachable application routes.

The cluster supports Phase 1 validation and prepares Phase 2 GitOps work. The initial test proves that the developer workstation can start and delete a Kubernetes environment. It does not bootstrap Flux or deploy the sample service yet.

## Required tools

| Tool | Purpose | Status at Phase 1 setup |
|---|---|---|
| Docker Desktop | Provides the local container runtime used by Kind. | Available and running. |
| Kind | Creates the disposable Kubernetes nodes as local containers. | Installed. |
| kubectl | Checks cluster health and later validates manifests. | Installed. |
| Git | Manages source history and reviewed changes. | Installed. |
| GitHub CLI | Manages repository operations when explicitly approved. | Installed and authenticated. |
| Helm and Flux CLI | Required in Phase 2, not required to create the initial Kind cluster. | Deferred. |

## Preflight

Run the following checks from the repository root before creation:

```sh
docker info --format '{{.ServerVersion}}'
kind version
kubectl version --client --output=yaml
```

Continue only if Docker reports a server version and both Kind and `kubectl` return version output. Confirm that no existing cluster uses the name `lab-to-interview-dev`:

```sh
kind get clusters
```

If the name already exists, inspect it before deletion. Do not delete an unfamiliar cluster. A cluster created by this project should have no valuable data because it is intentionally disposable.

## Create the cluster

From the repository root, run:

```sh
kind create cluster --name lab-to-interview-dev --wait 60s
```

Then verify Kubernetes access and core system health:

```sh
kubectl cluster-info --context kind-lab-to-interview-dev
kubectl get nodes --context kind-lab-to-interview-dev
kubectl get pods --all-namespaces --context kind-lab-to-interview-dev
```

The expected Phase 1 result is one Ready control-plane node and healthy system pods. Record only sanitized output in a Phase 1 evidence note. Do not publish local addresses, container identifiers, or user-specific paths.

## Validate the disposable lifecycle

Use the following checklist before declaring the development baseline ready:

| Check | Pass condition | Evidence ID |
|---|---|---|
| Creation | Kind completes cluster creation without retrying through undocumented manual steps. | E-003 |
| Context | `kubectl` uses `kind-lab-to-interview-dev` for the project check. | E-003 |
| Node health | The project node is `Ready`. | E-003 |
| System health | Core system pods reach expected healthy states. | E-003 |
| No external exposure | No domain, tunnel, public ingress, or home-router change exists. | E-002 |
| Teardown | The cluster deletes cleanly and no project-specific persisted cluster remains. | E-003 |
| Rebuild | A second creation follows the same written commands and returns to health. | E-003 |

## Teardown

Delete only the named disposable project cluster:

```sh
kind delete cluster --name lab-to-interview-dev
kind get clusters
```

The final command must not list `lab-to-interview-dev`. The repository and its documentation remain intact. Do not delete Docker Desktop volumes, unrelated containers, or other Kind clusters without separate confirmation.

## Evidence capture

Create `docs/evidence/phase-1-development-baseline.md` after completing the create-delete-recreate exercise. Record the date, tool versions, commands used, expected and actual results, elapsed time, redacted health output, teardown result, and any discrepancy. Update this runbook when the observed procedure differs from the documented procedure.

## Troubleshooting boundary

| Symptom | Safe first check | Escalation boundary |
|---|---|---|
| Docker is unavailable | Start Docker Desktop and re-run `docker info`. | Do not reinstall, reset, or delete Docker data without explicit approval. |
| Kind command missing | Confirm the executable location with `command -v kind`. | Reinstall only through the documented package manager procedure. |
| Node is not Ready | Inspect `kubectl get nodes` and system pods for the project context. | Do not alter unrelated clusters, host firewall, router, or VPN settings. |
| Wrong context | List contexts and select only the documented project context. | Do not delete or modify unfamiliar contexts. |
| Creation uses unsupported image behavior | Record the Kind and Docker versions and inspect the project documentation. | Do not bypass security settings or download unreviewed scripts. |

## Phase 2 handoff

Phase 2 will add a current Flux installation method, Helm only if a selected component requires it, manifest rendering checks, the Signalboard source code, a container build, and GitOps reconciliation. Keep this cluster disposable until those steps have passed their own validation gates.

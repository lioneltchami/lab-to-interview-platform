# ADR 0004: Plan a Talos-Based Durable Kubernetes Cluster

**Status:** Accepted as the Phase 3 direction
**Date:** 2026-08-28
**Decision owner:** Repository maintainer
**Review trigger:** Hardware inventory completion, a change in target learning outcomes, or a successful local platform baseline that identifies a blocking compatibility issue.

## Context

The durable Lab to Interview environment should support an explicit platform-engineering story. The project needs a predictable node configuration process, a clean operating-system boundary, controlled upgrades, and a topology that matches any availability claim.

The connected development workstation uses ARM architecture and Docker. It is appropriate for disposable local validation but does not decide the durable cluster’s hardware. The project will collect a physical inventory and define the availability expectation before configuration begins.

## Decision

Lab to Interview will plan for Talos Linux as the operating-system direction for the durable Kubernetes cluster in Phase 3. Talos aligns with the project’s desired-state, API-managed, minimal-node story. The project will not purchase, reimage, or configure durable hardware until Phase 2 proves the application delivery loop and Phase 3 records actual hardware constraints.

The project will use a three-control-plane topology only if the hardware, network, load-balancer path, backup plan, and validation evidence support an explicit high-availability claim. Otherwise, the documentation will state the actual topology and availability limits.

## Decision criteria

| Criterion | Requirement | Validation |
|---|---|---|
| Configuration model | Node configuration can be created, reviewed, applied, and documented without hidden manual steps. | A clean node bootstrap follows a versioned runbook. |
| Security boundary | The platform minimizes unnecessary general-purpose host administration and records privileged access. | Security design identifies node-management paths and credential lifecycle. |
| Hardware fit | The selected node architecture, memory, storage, network, and power meet the actual workload needs. | Hardware inventory and capacity assumptions are reviewed before provisioning. |
| Availability honesty | The claimed resilience matches the implemented topology and observed tests. | Architecture diagram and case study state the real failure domain and recovery plan. |
| Teaching value | The node platform supports a lesson about immutable or declarative infrastructure. | Learners can connect the node design to a tested operational workflow. |

## Consequences

| Benefit | Cost or limitation | Mitigation |
|---|---|---|
| The durable cluster has a focused, declarative platform story. | The project must learn Talos-specific bootstrap and recovery procedures. | Use the disposable development environment to validate Kubernetes configuration before hardware work. |
| Node drift becomes easier to reason about. | Some general Linux host-administration exercises sit outside the core path. | Add a separate optional host-administration lesson later if it serves a stated learning objective. |
| Availability claims can be tied to a documented topology. | A multi-control-plane cluster requires more hardware and operational planning. | State a smaller initial topology honestly if the evidence does not support an HA design. |

## Security and privacy impact

Talos machine secrets, client configuration, bootstrap credentials, node network information, and any hardware serial data are private. They will not enter the public repository. The project will document generated file locations, encryption boundaries, and recovery controls without publishing live values.

## Validation plan

| Test or observation | Pass condition | Evidence location |
|---|---|---|
| Hardware inventory | Every node and dependency has a role, resource profile, network link, and storage plan. | `docs/architecture/hardware-inventory.md`. |
| Bootstrap | A newly provisioned node joins through the documented method. | Phase 3 bootstrap runbook and evidence record. |
| Upgrade | A non-critical test environment completes a documented node upgrade. | Phase 3 maintenance record. |
| Recovery | The project completes the control-plane recovery procedure that matches its topology. | Phase 4 recovery documentation and restore evidence. |

## Alternatives considered

| Alternative | Strength | Reason not selected now |
|---|---|---|
| k3s on Ubuntu. | Builds general Linux administration experience with a simpler initial path. | It creates more host-level configuration drift than the core project wants to manage. |
| A managed cloud Kubernetes service. | Reduces hardware and node-management burden. | It does not create the local infrastructure operations learning path that the project targets. |
| Raspberry Pi-only cluster. | Accessible hardware and low power draw. | It can shift the project’s focus toward ARM compatibility and peripheral reliability rather than platform operating practice. |

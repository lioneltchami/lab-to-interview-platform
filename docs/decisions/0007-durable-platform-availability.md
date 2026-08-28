# ADR 0007: Claim a Single-Control-Plane Durable Learning Environment First

**Status:** Accepted for Phase 3 design; hardware activation pending inventory
**Date:** 2026-08-28
**Decision owner:** Repository maintainer

## Context

The project has proven a stateless Signalboard workload in a disposable Kind cluster. Phase 3 introduces the design for a durable Talos-based environment. The project must avoid stating an availability level that its hardware, control-plane endpoint, storage, and failure evidence do not support.

Talos documents that a three-member control plane requires two members for etcd quorum and can tolerate one member failure. It also explains why a two-member control plane has no equivalent failure tolerance. [1] Talos production guidance recommends a control-plane endpoint that can reach all control-plane nodes when high availability is the goal. [2]

## Decision

The first durable profile is **D1: a single-control-plane durable learning environment**. It will use a reimageable Talos-capable host with sufficient compute, memory, local storage, wired network, and stable power according to the Phase 3 design document. Workloads may be scheduled only according to the selected capacity model, which will be documented after the actual inventory.

The project may evolve to **D2: a three-member high-availability control plane** only after the operator supplies the necessary hardware, a resilient Kubernetes API endpoint is designed, the endpoint and node failure behavior are tested, and the evidence index is updated. A two-control-plane configuration is rejected.

## Consequences

| Consequence | Impact |
|---|---|
| Honest initial claim | The lab can demonstrate immutable node lifecycle, GitOps, policy, and private access without claiming control-plane HA. |
| Lower first operational cost | A durable learning node can be started from repurposed equipment rather than requiring a full multi-node purchase. |
| Explicit expansion path | Three control planes remain a documented future exercise with quorum, endpoint, and replacement evidence. |
| Controlled storage scope | Persistent storage and application data remain deferred until Phase 4 recovery requirements are ready. |

## Alternatives considered

| Alternative | Decision | Reason |
|---|---|---|
| Start with three control planes and workers | Deferred | It is valid when HA is a named objective, but it expands hardware, endpoint, power, storage, and operational requirements before Phase 3 has its first durable-node evidence. |
| Run two control planes | Rejected | It does not provide safe one-node etcd failure tolerance. [1] |
| Keep Kind as the durable environment | Rejected | Kind remains the disposable development environment; it does not demonstrate durable node configuration or physical-network boundaries. |
| k3s on a general-purpose Linux host | Deferred | This is a defensible alternative when host administration is the primary learning goal. The current platform focus is immutable Kubernetes node operations. |

## Validation plan

Before D1 activation, complete the hardware inventory, validate Talos compatibility, create sanitized machine-configuration templates, and perform a documented node bootstrap. Before D2 can be claimed, demonstrate a three-member control plane, resilient API endpoint, one-node failure tolerance, and the prescribed recovery/replacement path.

## Review trigger

Review this ADR before procuring hardware, before adding a second durable node, and before any portfolio language uses the phrase “high availability.”

## References

[1]: https://docs.siderolabs.com/talos/v1.13/learn-more/control-plane "Talos Linux — Control Plane"
[2]: https://docs.siderolabs.com/talos/v1.13/getting-started/prodnotes "Talos Linux — Production Clusters"

# ADR 0009: Adopt the D1 Single-Control-Plane Durable Learning Profile

**Status:** Accepted
**Date:** 2026-08-28
**Decision owner:** Repository maintainer

## Context

The project has completed a disposable Kind-based development implementation, protected its public canonical repository, and established a Phase 3 durable-platform design. The maintainer must now choose a first durable profile that is useful for teaching and interview discussion without adding hardware, identity, networking, or availability complexity that cannot yet be justified.

The available Phase 3 profiles are defined in [Phase 3 Durable Platform Design](../phase-3-durable-platform.md). Talos explains that three control-plane members are required for a quorum-tolerant high-availability control plane, while a single control plane must be described accurately as a non-HA environment. [1]

## Decision

Adopt **D1: a single-control-plane durable Talos learning environment** as the first durable implementation target.

The D1 environment will use one reimageable, wired, Talos-compatible host with at least four CPU cores, 16 GiB memory, and 256 GiB SSD or NVMe capacity as the starting capability target. It will use private LAN access with a stable DHCP reservation, no public ingress, no router port forwarding, no public DNS, no VPN or identity provider, and no claim of high availability. Cilium, encrypted secret handling, a container registry, and traffic management are deferred until their relevant use cases and owner decisions are ready.

## Consequences

| Benefit | Constraint |
|---|---|
| Establishes real immutable-node lifecycle and durable-cluster skills on a manageable footprint. | Control-plane availability depends on one node and maintenance causes a control-plane outage. |
| Retains the established GitOps, Pod Security, and private-access design without increasing external attack surface. | No remote user journey, public demo, or production-reliability claim is permitted. |
| Creates a clean future D2 expansion path based on three control-plane nodes and a resilient endpoint. | D2 must be an intentional future decision, not an assumption derived from this profile. |
| Keeps the first implementation teachable: one host, one clearly stated boundary, and one recovery path. | Hardware inventory, private network details, generated configuration, and bootstrap credentials remain outside public Git. |

## Alternatives considered

| Alternative | Decision | Reason |
|---|---|---|
| D2 three-control-plane HA cluster | Deferred | It becomes valuable only when quorum, endpoint resilience, and one-node failure behavior are the deliberate learning objectives. |
| Two-control-plane cluster | Rejected | It does not offer the intended one-node quorum tolerance. [1] |
| Continue with Kind only | Rejected as a durable target | Kind remains useful for disposable development but does not exercise physical-node lifecycle and durable-cluster constraints. |
| Publicly exposed application route | Rejected for D1 | The project currently has no use case that justifies the added access, identity, TLS, and incident-response responsibilities. |
| Immediate VPN, identity provider, or self-hosted forge | Deferred | These add operational responsibility before a specific user need requires them. |

## Acceptance criteria

D1 is ready to bootstrap only after the selected device is inventoried, reimage authorization is explicit, private management access is established, Talos/Cilium/Flux versions are reviewed, a private operator workspace exists, generated credentials are excluded from Git, and the bootstrap and recovery paths have been read.

## Review trigger

Review this decision before selecting a second durable node, enabling remote access, introducing application state, exposing a route, or using the words “high availability” in teaching or portfolio material.

## Reference

[1]: https://docs.siderolabs.com/talos/v1.13/learn-more/control-plane "Talos Linux — Control Plane"

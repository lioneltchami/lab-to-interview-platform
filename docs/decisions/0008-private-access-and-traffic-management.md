# ADR 0008: Keep the Durable Platform Private and Defer Traffic Management

**Status:** Accepted for Phase 3 design
**Date:** 2026-08-28
**Decision owner:** Repository maintainer

## Context

Signalboard currently uses an internal Kubernetes Service and is reached for verification through a temporary local port-forward. The project has no current user journey that requires a publicly reachable route, no identity provider, no certificate authority, no domain ownership decision, and no remote-access revocation procedure. Adding Ingress, Gateway API, a tunnel, a VPN operator, or an identity provider before those needs exist would increase complexity without producing verified value.

Kubernetes Pod Security controls apply to workload behavior at the namespace level, while network policy enforcement requires a network implementation that supports it. [1] Cilium supports standard Kubernetes NetworkPolicy and optional Cilium-specific rules. [2]

## Decision

Keep the Kubernetes API, Talos API, and application traffic **private by default**. Retain Signalboard as a ClusterIP Service and local port-forward path in the disposable development cluster. The Phase 3 durable design will use the same private starting point.

Select Cilium as the planned durable-cluster CNI because it can enforce the standard NetworkPolicy resources already declared by the application. Install Cilium by a version-pinned, GitOps-managed method only after the durable hardware profile, Talos version, and first node are approved. Do not deploy Gateway API, Ingress, a VPN operator, a hosted identity provider, public DNS, certificates, a public tunnel, or router port forwarding in this decision.

## Consequences

| Consequence | Impact |
|---|---|
| Reduced exposure | There is no external application endpoint or publicly reachable control plane to secure in the initial durable design. |
| Clear policy learning path | The default-deny policy is in Git now, and later Cilium enforcement tests can demonstrate both denied and permitted paths. |
| Deferred routing choice | Gateway API and Ingress remain candidates only when a real internal or authenticated user journey requires HTTP routing. |
| Explicit remote-access gate | An overlay network or identity solution requires a named operator, revocation process, recovery access, and user approval before deployment. |

## Alternatives considered

| Alternative | Decision | Reason |
|---|---|---|
| Public Ingress with a domain and TLS | Deferred | No portfolio or learner use case currently justifies public attack surface and certificate operations. |
| Gateway API immediately | Deferred | It is valuable when role-oriented traffic policy or multiple routes are needed, not for a single internal service. |
| Self-hosted identity provider immediately | Deferred | It adds a stateful and security-sensitive application before a user-facing access requirement exists. |
| Overlay network immediately | Deferred | It may be a good later private-access mechanism, but only after access owner, endpoint inventory, revocation, and recovery paths are defined. |
| A default-deny NetworkPolicy without an enforcing CNI | Accepted as declaration only | It makes the desired isolation visible now but is not considered tested enforcement until Cilium is installed and connectivity tests pass. |

## Validation plan

Before Cilium installation, add a specific version and installation method to the durable-cluster bootstrap plan. Once active, test: a non-authorized client is denied; an explicitly authorized path can reach Signalboard on the required port; unintended egress is denied; and removal of the allow rule restores denial. If a route is later introduced, add an allow rule for the named controller only and confirm that no direct public route exists.

## Review trigger

Review this ADR before changing a Service type, introducing any external address, configuring DNS or certificates, adding an identity component, adding remote access, or selecting Gateway API or Ingress.

## References

[1]: https://kubernetes.io/docs/concepts/security/pod-security-admission/ "Kubernetes — Pod Security Admission"
[2]: https://docs.cilium.io/en/stable/network/kubernetes/policy/ "Cilium — Network Policy"

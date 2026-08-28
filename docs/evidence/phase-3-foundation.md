# Phase 3 Foundation Evidence

**Status:** Partially verified — durable hardware activation is intentionally pending
**Evidence date:** 2026-08-28
**Environment:** Disposable Kind development cluster and public sanitized repository
**Classification:** Public after review
**Repository revision:** `85cbcd4b77c04649a12bd10645806f30b3516021`

## Scope

This record captures the verified Phase 3 design foundation and the first implemented workload-policy controls. It does **not** claim that a durable Talos cluster, Cilium policy enforcement, encrypted secret workflow, private remote access, DNS, TLS, staging environment, production environment, or high-availability control plane exists. Those outcomes require actual hardware and private operator decisions.

## Verified foundation

| Area | Evidence | Result |
|---|---|---|
| Durable-platform scope | [Phase 3 Durable Platform Design](../phase-3-durable-platform.md) and [ADR 0007](../decisions/0007-durable-platform-availability.md) | A D1 single-control-plane durable learning profile is the initial proposed claim; D2 three-control-plane HA remains a separately gated future profile. |
| Private-access boundary | [ADR 0008](../decisions/0008-private-access-and-traffic-management.md) | Kubernetes API, Talos API, and Signalboard remain private by default; no external route, domain, certificate, tunnel, remote-access service, router change, or DNS record was created. |
| Hardware readiness | [Hardware Inventory Template](../hardware-inventory-template.md) | A sanitized inventory and reimage authorization are mandatory before durable bootstrap. No hardware decision was assumed. |
| Talos secret boundary | [`talos/README.md`](../../talos/README.md), generic CNI patch, and `.gitignore` exclusions | Templates may be reviewed publicly; generated Talos credentials, private configuration, exact addresses, and keys are prohibited from Git. |
| Policy declaration | [Signalboard namespace](../../apps/base/signalboard/namespace.yaml), [default-deny NetworkPolicy](../../apps/base/signalboard/network-policy.yaml), and manifest validator | The GitOps application base renders a restricted Pod Security namespace and a standard ingress/egress default-deny policy. |
| Pod Security enforcement | [Live admission verifier](../../tests/policy/verify-signalboard-pod-security.sh) | The Signalboard namespace reports `enforce=restricted`, `audit=restricted`, and `warn=restricted`, all pinned to v1.37. A deliberately privileged Pod was rejected by server-side admission. |
| GitOps reconciliation | Flux source and Kustomizations on the Kind cluster | `flux-system` GitRepository and both Kustomizations were `Ready=True` at revision `main@sha1:85cbcd4b`; Signalboard rollout and internal service verification passed. |
| Regression checks | Application tests, Kustomize renderer, repository validator, and pull-request checks | Five application tests passed; manifest and repository validation passed locally and in the protected pull-request workflow. |

## Implementation observations

Pod Security Admission is a built-in Kubernetes control that uses namespace labels for enforcement, audit, and warning behavior. [1] The Signalboard namespace now uses the `restricted` profile for all three modes. Cilium is the planned durable-cluster CNI, and it can enforce the standard Kubernetes NetworkPolicy resource that the project declared. [2] [3]

The default-deny policy is deliberately described as **declared**, not **enforced**, in the current Kind environment. The project will only mark network isolation verified after a Cilium-enabled durable cluster proves both a denied path and a narrowly authorized path.

## Remaining Phase 3 acceptance gates

| Evidence ID | Gate | Current state |
|---|---|---|
| E-007 | Actual sanitized hardware inventory, D1/D2 selection, and durable Talos bootstrap | Pending user decision and reimage authorization |
| E-008 | Cilium-enabled allowed/denied connectivity test | Policy declared; enforcement pending durable CNI installation |
| E-009 | Secret-management decision, key custody, and authorized bootstrap test | Deferred until a real secret exists |
| Phase 3 environment separation | Staging and production-shaped overlays reconcile independently | Deferred until durable topology and image-registry model are selected |
| Durable image identity | Registry selection, digest-pinned promotion, and rollback | Deferred until registry publication is approved |

## References

[1]: https://kubernetes.io/docs/concepts/security/pod-security-admission/ "Kubernetes — Pod Security Admission"
[2]: https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium "Talos Linux — Deploy Cilium CNI"
[3]: https://docs.cilium.io/en/stable/network/kubernetes/policy/ "Cilium — Network Policy"

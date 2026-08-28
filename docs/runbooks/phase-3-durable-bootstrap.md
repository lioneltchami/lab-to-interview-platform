# Phase 3 Durable Talos Bootstrap Runbook

**Status:** Prepared, blocked on actual hardware and private operator inputs
**Audience:** Authorized platform operator
**Scope:** First durable Talos node or later three-node control-plane expansion
**Safety boundary:** This runbook must be executed only with reimage authorization. It does not authorize public access, router changes, creation of credentials in the public repository, or installation on a device that has not been inventoried.

## Outcome

This runbook produces a private Talos Kubernetes environment that can later receive Flux-managed configuration. For the initial D1 profile, it establishes a **single-control-plane durable learning environment**, not high availability. A D2 profile follows the same staged process only after three control-plane nodes and a resilient endpoint have been approved.

## Preconditions

| Gate | Required state | Evidence |
|---|---|---|
| Hardware inventory | Completed private copy of `docs/hardware-inventory-template.md`; selected D1 or D2 profile | Sanitized inventory summary and approved availability ADR |
| Reimage authority | Owner explicitly confirms that the selected system disk may be erased | Dated operator record outside public Git |
| Network boundary | Private management path, stable addressing plan, and recovery console known | Sanitized topology diagram and private operator worksheet |
| Version decisions | Talos, Kubernetes, Cilium, Flux, and architecture-specific extension versions reviewed together | Approved pull request with version table |
| Credentials | Private local workspace exists with restricted access; no generated secret has entered Git | `git status` and repository validator pass |
| CNI plan | Cilium pre-bootstrap dependency is reviewed for the selected Talos version | Version-pinned configuration and deployment plan |
| Recovery | Operator knows how to power-cycle, use local console, and return to a known physical state | Inventory recovery field complete |

Stop if any gate is incomplete. Do not substitute guessed interface names, disk names, IP addresses, or secrets.

## Private operator workspace

Create a private workspace that is outside the public repository. The workspace stores generated Talos secrets, `talosconfig`, kubeconfig, exact endpoints, machine configurations, and any hardware-specific patches. Restrict it to the operator account. Maintain a separate recovery record that identifies the secure storage location of the generated material without recording the material in Git.

Before generation, verify that the selected `talosctl` release is compatible with the selected Talos version. Talos recommends matching the client and installed operating-system versions when creating configurations. [1]

## Bootstrap procedure

1. **Record versions and inspect the node.** Boot the Talos installation media on the reimageable target. From the private workspace, identify the live network interface and target installation disk using Talos discovery commands. Record only the sanitized outcome in the repository.
2. **Generate reviewed configuration.** Use the selected cluster name and private Kubernetes endpoint in the private workspace. Apply only reviewed configuration patches. A D1 endpoint may name the single private control plane. A D2 endpoint must route to all control-plane nodes. [1]
3. **Prepare Cilium dependency.** If Cilium is selected, ensure the final machine configuration reflects the selected custom-CNI dependency before bootstrap. Do not use an unreviewed hosted manifest; Talos warns that a generated Cilium manifest can contain sensitive key material. [2]
4. **Apply configuration to the intended node or nodes.** Use the private addresses and target installation disk verified in Step 1. Pause immediately if discovery output does not match the private inventory.
5. **Bootstrap exactly once.** For a new control-plane cluster, invoke the bootstrap operation on one selected control-plane node only. Do not repeat bootstrap to troubleshoot a Kubernetes readiness failure. [3]
6. **Install the selected CNI.** Apply the version-pinned, reviewed Cilium release during the documented bootstrap window. Wait for nodes to become ready before proceeding. [2]
7. **Verify base health.** Confirm control-plane membership, node readiness, CoreDNS, Cilium health, and API reachability over the intended private path. Keep raw outputs private; commit a redacted evidence summary.
8. **Bootstrap Flux.** Apply the reviewed Flux source and Kustomizations only after the CNI and base cluster are healthy. Confirm Flux is reconciling the intended sanitized repository paths.
9. **Reconcile Signalboard.** Confirm Pod Security Admission accepts Signalboard, the default-deny NetworkPolicy is active, the Service remains ClusterIP, and no external route exists.
10. **Capture evidence and stop.** Create a bootstrap record with date, selected profile, software versions, redacted health checks, Git revision, Flux revision, Signalboard version, and known limitations. Do not add remote access or a public route during this procedure.

## D1 and D2 verification matrix

| Test | D1 requirement | D2 additional requirement |
|---|---|---|
| Talos control-plane health | One member healthy | All three members healthy |
| Kubernetes endpoint | Private endpoint reachable by authorized operator | Endpoint remains reachable after one control-plane member is deliberately unavailable |
| etcd | Healthy single-member state, accurately documented | Quorum remains healthy with one member unavailable |
| CNI | Cilium healthy and standard NetworkPolicy enforcement tested | Same, including policy behavior after a node failure |
| Flux | Git source and target Kustomizations `Ready=True` | Same after a control-plane restart or member loss |
| Signalboard | Restricted Pod Security accepted; internal service works only on authorized path | Same while one node is unavailable, if workload placement and capacity support it |
| Public exposure | No public route or management endpoint | No public route or management endpoint |

## Failure handling

| Signal | Immediate action | Do not do |
|---|---|---|
| Node does not appear on expected private network | Stop and compare physical console output to the private inventory | Guess interface names or change router settings without review |
| Target disk is ambiguous | Stop and verify the device locally | Apply machine configuration or installation to an uncertain disk |
| Cluster bootstrap appears incomplete | Check etcd and control-plane health, then correct configuration as documented | Run the bootstrap operation again |
| Cilium leaves nodes unready | Review the selected Talos CNI configuration and Cilium health | Bypass policy or install an unpinned replacement CNI |
| Signalboard is rejected by Pod Security | Inspect the rejection; repair the workload manifest | Weaken the namespace label globally without an ADR |
| Network policy blocks desired path | Define the exact authorized caller and add the minimum allow rule through Git | Delete the default-deny policy as a troubleshooting shortcut |
| Secret appears in `git status` or a scan fails | Remove the material from the worktree, rotate it if real, and investigate | Commit it, encode it, or add an ignore rule that hides a real exposure |

## Required evidence record

The first durable bootstrap record must state the selected availability profile, non-claims, Talos/Kubernetes/Cilium/Flux versions, redacted health outcome, private-access boundary, Signalboard Git and image revision, Pod Security outcome, network-policy test result, and next review date. It must explicitly state whether it used a single control plane or an HA control plane.

## References

[1]: https://docs.siderolabs.com/talos/v1.13/getting-started/prodnotes "Talos Linux — Production Clusters"
[2]: https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium "Talos Linux — Deploy Cilium CNI"
[3]: https://docs.siderolabs.com/talos/v1.13/learn-more/control-plane "Talos Linux — Control Plane"

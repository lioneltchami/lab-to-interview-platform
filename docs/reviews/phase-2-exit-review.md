# Phase 2 Exit Review

**Review status:** Passed for the stated local GitOps scope, with two governance gates required before durable-platform execution
**Review date:** 2026-08-28
**Current reviewed commit:** `6e064dd2d0d0982084627cc1d603647d48b74c7e`
**Environment:** Freshly recreated local Kind development cluster on an ARM-based macOS workstation
**Reviewer:** Manus AI

## Decision

Phase 2 is **accepted as complete**. The project now has a small original workload that can be built, tested, deployed from a public canonical repository into a disposable local Kubernetes cluster through Flux, and returned to a known-safe state by reverting Git configuration. The review re-ran the full bootstrap against a newly recreated cluster rather than relying on the prior running state.

Phase 3 **planning** may begin. Before Phase 3 creates or connects any durable node, enables secrets, accepts outside contributors, or makes infrastructure declarations with real operational impact, the two governance gates in this review must be completed: protect the canonical branch and enable provider-side secret scanning. The current Phase 2 implementation contains no credentials, live endpoint, physical-network configuration, persistent data, or personal data.

## Review method

The review used a layered, evidence-first method. Source and configuration were inspected in the public repository; local application, manifest, and repository checks were rerun; container runtime assumptions were tested under the declared read-only filesystem; the live local deployment was inspected; least-privilege checks were executed for the workload ServiceAccount; public repository governance settings were queried; and the Kind cluster was deleted, recreated, bootstrapped, reconciled, and verified again from the latest canonical commit.

Flux’s documented model separates a GitRepository source artifact from a Kustomization that fetches, builds, validates, applies, and can health-check declared configuration. [1] [2] The review therefore treats successful workloads without an observed source revision as insufficient. The final rebuild verified both the Flux source revision and the two reconciliation states.

## Acceptance-gate assessment

| Gate | Review evidence | Result | Assessment |
|---|---|---|---|
| Original bounded workload | Source tree, product brief, synthetic domain data, and tracked-file boundary scan. | Pass | Signalboard is original, stateless, read-only, and uses deterministic synthetic status and incident information. No archive asset, package, or reference artifact is tracked. |
| Application behavior | Five native Node.js tests covering status, health, version, root UI, safe missing-route and method errors, security headers, and structured-log query exclusion. | Pass | All five tests passed during the review. The service exposes an intentionally narrow GET-only contract. |
| Local container behavior | Fresh build from the reviewed Dockerfile; ARM64 image inspection; runtime under read-only filesystem with writable temporary directory; readiness and version checks. | Pass | The container ran as the unprivileged `node` user and served expected responses with `readOnlyRootFilesystem` conditions reproduced locally. |
| Image reproducibility | Dockerfile inspection and registry manifest inspection. | Pass after correction | The review found an initial floating `node:22-alpine` base tag. It was corrected to the reviewed multi-platform manifest digest in commit `6e064dd`, then rebuilt and validated. |
| Declarative manifest integrity | Local Kustomize render; server-side apply dry run; application and cluster configuration policy assertions. | Pass | The development overlay renders exactly one Namespace, ServiceAccount, ConfigMap, Deployment, and ClusterIP Service. Server-side validation accepted the rendered resources. |
| Workload hardening | Rendered and live Deployment inspection. | Pass | The Pod declares `runAsNonRoot`, UID/GID 1000, runtime-default seccomp, disabled privilege escalation, all capabilities dropped, read-only root filesystem, resource requests/limits, and startup/liveness/readiness probes. |
| Workload identity minimization | Live ServiceAccount authorization queries and Pod volume inspection. | Pass | The Signalboard identity could not get Pods, list Secrets, or create Deployments in its namespace. No service-account token volume was present. |
| Exposure boundary | Live Service inspection; Ingress absence check; verifier port-forward path. | Pass | The service is `ClusterIP` with no external address. There is no Ingress in the Signalboard namespace. Verification requires a temporary local port-forward. |
| GitOps bootstrap | Bootstrap-script review, controller status, CRD ordering, and a fresh-cluster reconstruction. | Pass after correction | An initial test identified a CRD-ordering defect. The script now installs controller resources, waits for the GitRepository and Kustomization CRDs, waits for controllers, and then creates GitOps custom resources. The full process passed on a fresh cluster. |
| Git-to-cluster delivery | Source-level delivery commit `7338ff5`, local image load, Flux source status, Flux Kustomization status, and internal endpoint test. | Pass | The review confirmed the versioned image and a newly introduced status-marker field were visible through the internal service at the same Flux source revision. |
| Git-based rollback | Revert commit `bd0377a`, reconciliation status, final version response, and elapsed-time capture. | Pass | A Git revert—not a live Deployment or ConfigMap patch—restored the `0.1.0-dev` baseline. The measured end-to-end exercise completed in 15 seconds. |
| CI coverage | Public GitHub Actions results for repository validation and Phase 2 validation at the pinned-base-image commit. | Pass | Both workflows completed successfully for `6e064dd`. |
| Repository safety baseline | Local hygiene validator, controlled negative test, remote workflow, public repository settings, and history sample. | Partial—see governance gates | Local and workflow checks passed, but the canonical branch is not protected and repository-level secret-scanning settings are disabled. |

## Fresh-cluster reconstruction result

The strongest Phase 2 check was a disposable lifecycle test executed during this review. The existing Kind cluster was deleted, a new `lab-to-interview-dev` cluster was created, the local `signalboard:0.1.0-dev` image was loaded, and the bootstrap script was run from the current repository state. Flux fetched `main@sha1:6e064dd2d0d0982084627cc1d603647d48b74c7e`; both the root `flux-system` and child `signalboard` Kustomizations reached `Ready=True`; and the verifier confirmed rollout, internal service access, the `0.1.0-dev` version response, structured logs, and absence of public exposure.

This reconstruction demonstrates that Phase 2 is not dependent on accumulated local Kubernetes state. It does not prove production portability: the local image transfer is deliberately explicit and manual, and the underlying cluster is a disposable single-node Kind environment.

## Corrections made during review

| Finding | Severity at discovery | Resolution | Verification |
|---|---|---|---|
| Container base used a mutable tag. | Moderate reproducibility concern | Pinned `node:22-alpine` to `sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32`. | Fresh image build, non-root read-only runtime check, Node test suite, manifest validation, and both remote workflows passed. |
| Flux bootstrap attempted GitRepository and Kustomization objects before their CRDs were established. | Bootstrap correctness defect | Ordered controller install, CRD establishment waits, controller rollout waits, then GitOps custom-resource creation. | Passed after a full delete-and-recreate cluster test. |
| Manifest validation assumed a fixed `0.1.0-dev` image tag. | Validation maintainability defect | Validator now derives the declared tag from the development overlay, with an explicit override for controlled exercises. | Passed for baseline and release-change tests. |
| A strict-shell pipeline could report a false log assertion failure after `grep -q` returned early. | Test reliability defect | Verifier captures log output before its direct shell match. | End-to-end verifier passed repeatedly. |

## Residual risks and Phase 3 entry gates

| ID | Finding | Risk | Required disposition |
|---|---|---|---|
| G-1 | `main` has no branch protection rule. | A direct push could alter the public GitOps source without required review or required successful checks. | **Required before durable-platform execution.** Protect `main` with required pull requests and the two existing validation checks; do not require a human approval until an independent reviewer exists. |
| G-2 | Repository-level secret scanning and push-protection settings were reported disabled. | Local pattern checks are useful but cannot provide provider-side history scanning or a repository-level prevention record. | **Required before durable-platform execution.** Enable secret scanning for this public repository and review the resulting alert state. Evaluate repository-level push protection against the account’s plan and contribution workflow. |
| R-1 | Commits sampled in the review were unsigned, and Flux source signature verification is not configured. | The public source has no cryptographic commit-authorship enforcement. | Plan an explicit trust and signing decision before adding secrets or granting additional writers; do not retrofit keys into Git history. |
| R-2 | Image delivery is a manual local Docker-to-Kind load. | The Git revision and local image content are coupled by procedure rather than immutable remote image provenance. | Expected in Phase 2. Phase 3 or a later delivery phase must introduce an evidence-backed image publication and digest-pinning decision before durable deployment. |
| R-3 | No Signalboard NetworkPolicy exists. | The workload has default cluster network reachability despite its minimal Kubernetes API permissions. | Expected in Phase 2. Phase 3 must add an explicit default-deny and narrowly test the service paths. |
| R-4 | The deployment has one replica and no persistent state. | It does not demonstrate availability, data durability, or recovery. | Expected by design. Do not describe this phase as high availability or disaster recovery. |
| R-5 | GitHub Actions test application and manifest render, but do not create a Kind cluster. | CI does not independently test a full GitOps reconciliation. | Accept for Phase 2 to keep the public workflow lightweight. Re-evaluate when the image publication strategy is introduced. |

GitHub documents branch rules as a mechanism for requiring pull requests and passing status checks before merge. [3] GitHub also documents secret scanning as available automatically and without charge for public repositories. [4] Those controls are appropriate for a public repository that acts as the canonical declaration of later infrastructure. Push protection prevents hardcoded secrets from reaching a repository, but repository-level configuration has plan and workflow considerations that should be reviewed before enabling it. [5]

## Scope boundaries confirmed

The following were deliberately **not** introduced or claimed in Phase 2: hardware purchase or node onboarding; local router changes; public DNS, ingress, or tunnels; long-lived external hosting; user accounts or authentication; real application data; databases or persistence; GitHub or cluster credentials stored in Git; self-hosted forge services; image publication; high availability; backup and restoration; production monitoring; alerting; or policy enforcement beyond the workload security context.

## Exit decision and next step

The Phase 2 implementation is technically sound for its stated **disposable local development** purpose. It has passed a fresh-cluster reconstruction, source-to-workload delivery proof, rollback proof, local hardening checks, and public CI validation. The correction commits and test history are retained as useful, transparent evidence of quality assurance rather than hidden.

Phase 3 should begin with its architecture and hardware decisions, not with device installation. Complete G-1 and G-2 as the first Phase 3 governance tasks; then define the durable-node topology, network access boundaries, and image-provenance approach before any hardware or private configuration is created.

## References

[1]: https://fluxcd.io/flux/components/source/gitrepositories/ "Flux — Git Repositories"
[2]: https://fluxcd.io/flux/components/kustomize/kustomizations/ "Flux — Kustomization"
[3]: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule "GitHub Docs — Managing a branch protection rule"
[4]: https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning "GitHub Docs — Secret scanning"
[5]: https://docs.github.com/en/code-security/concepts/secret-security/push-protection "GitHub Docs — Push protection"

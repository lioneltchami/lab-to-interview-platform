# Runbook: Phase 2 GitOps Delivery and Rollback

**Status:** Active Phase 2 procedure
**Environment:** Local Kind cluster only
**Scope:** Deploy the stateless synthetic Signalboard service from the public canonical repository with Flux, then prove a benign Git-based rollback.

## Safety boundary

This runbook uses the disposable `lab-to-interview-dev` Kind cluster, a public source repository, and a locally built image. It creates no public application route, DNS record, tunnel, durable physical workload, database, secret, user account, or image-registry credential. The Signalboard service remains synthetic and is reachable only by a temporary local `kubectl port-forward` during verification.

## Delivery model

| Layer | Responsibility |
|---|---|
| GitHub `main` | Canonical declared source for application, manifest, and Flux configuration. |
| Local Docker image | Supplies the local `signalboard:<version>` image loaded into the named Kind cluster. |
| Flux source controller | Retrieves the public repository without a repository credential. |
| Flux Kustomization `flux-system` | Reconciles the development-cluster declaration. |
| Flux Kustomization `signalboard` | Applies `apps/overlays/dev` and waits for the Signalboard deployment. |
| ClusterIP service | Makes Signalboard available only inside the cluster and through an explicit local port forward. |

## Preconditions

| Requirement | Verification |
|---|---|
| Repository is clean and current. | `git status --short --branch` reports no changes and tracks `origin/main`. |
| Phase 1 local cluster exists. | `kind get clusters` includes `lab-to-interview-dev`; node is `Ready`. |
| Local tools are available. | `docker`, `kind`, `kubectl`, `flux`, `node`, and `npm` resolve on the command line. |
| Application tests pass. | `cd platform-app && npm test`. |
| Manifests render. | `bash scripts/render-manifests.sh`. |
| No live secrets are required. | Configuration uses only the non-secret `PORT` and `APP_VERSION` values. |

## Initial delivery

From the repository root, complete the following commands in order:

```sh
cd platform-app
npm test
docker build --tag signalboard:0.1.0-dev .
cd ..
bash scripts/render-manifests.sh
bash scripts/bootstrap-flux-dev.sh
bash scripts/verify-phase2-delivery.sh
```

The bootstrap script loads `signalboard:0.1.0-dev` into the named Kind cluster, applies the reviewed Flux controller and self-sync configuration, waits for the required controllers, and reconciles the public repository. The verification script requires healthy Flux objects, a successful Deployment rollout, a `ClusterIP` service, successful temporary local access to the readiness and version endpoints, and a structured request log.

## Benign release-change exercise

Use this exercise to prove that a declared Git change reaches the local cluster. It changes only the synthetic release identifier; the source code and service behavior remain unchanged.

1. Build and load a second local tag:

   ```sh
   cd platform-app
   docker build --tag signalboard:0.1.1-dev .
   cd ..
   kind load docker-image signalboard:0.1.1-dev --name lab-to-interview-dev
   ```

2. Change both `newTag` in `apps/overlays/dev/kustomization.yaml` and `APP_VERSION` in `apps/overlays/dev/version-configmap-patch.yaml` from `0.1.0-dev` to `0.1.1-dev`.

3. Run `bash scripts/render-manifests.sh`, commit the change, push it to `main`, then force the GitOps update:

   ```sh
   flux reconcile source git flux-system --context kind-lab-to-interview-dev -n flux-system
   flux reconcile kustomization signalboard --context kind-lab-to-interview-dev -n flux-system --with-source
   EXPECTED_VERSION=0.1.1-dev bash scripts/verify-phase2-delivery.sh
   ```

4. Record the commit identifier, image tag, Flux revision, deployment revision, endpoint output, and timestamp in the Phase 2 evidence note.

## Git-based rollback exercise

The rollback must use Git, not a manual cluster edit. Revert the single benign release-change commit, push the revert, then reconcile and verify the original version:

```sh
git revert <release-change-commit>
git push
flux reconcile source git flux-system --context kind-lab-to-interview-dev -n flux-system
flux reconcile kustomization signalboard --context kind-lab-to-interview-dev -n flux-system --with-source
EXPECTED_VERSION=0.1.0-dev bash scripts/verify-phase2-delivery.sh
```

The rollback succeeds only when the Git revert is visible in the canonical source, Flux reports the expected applied revision, Signalboard rolls out successfully, and `/api/v1/version` returns `0.1.0-dev` through the internal service. Record the revert commit and elapsed time. Do not describe this as database or disaster recovery; it is a declared-configuration rollback for a stateless local service.

## Failure handling

| Symptom | Safe investigation | Do not do |
|---|---|---|
| Image pull fails | Confirm the exact local tag and repeat `kind load docker-image` for the named disposable cluster. | Do not change the service to a public load balancer or add registry credentials. |
| Flux source is not ready | Check `flux get sources git -A` and the source-controller logs. Confirm the public repository URL and branch. | Do not add a personal token to Git or a plain manifest. |
| Signalboard Kustomization is not ready | Check `flux get kustomizations -A`, then inspect the named Kustomization and deployment events. | Do not apply the application manifests manually as a substitute for GitOps. |
| Deployment is not available | Check pod status, logs, image name, probe responses, and resource events. | Do not remove security contexts or probes to force readiness. |
| Version does not change | Confirm the image tag and ConfigMap version changed together, the new image was loaded before reconciliation, and Flux observed the new commit. | Do not patch the live Deployment or ConfigMap manually. |
| Rollback is delayed | Inspect Flux source and Kustomization revisions, then wait for rollout status. | Do not delete controllers, namespaces, or workload history. |

## Phase 2 completion evidence

Update `docs/evidence/phase-2-delivery.md` only after the initial deployment and rollback both pass. Link the application commit, release-change commit, revert commit, successful CI runs, rendered-manifest validation, Flux source status, Flux Kustomization status, deployment status, sanitized endpoint output, and known limitations.

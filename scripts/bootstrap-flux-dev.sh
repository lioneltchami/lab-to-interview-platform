#!/usr/bin/env bash
set -euo pipefail

context="${KUBE_CONTEXT:-kind-lab-to-interview-dev}"
kind_cluster="${KIND_CLUSTER_NAME:-lab-to-interview-dev}"
image_ref="${SIGNALBOARD_IMAGE:-signalboard:0.1.0-dev}"

fail() {
  printf 'Flux bootstrap failed: %s\n' "$1" >&2
  exit 1
}

for command in kubectl kind flux docker; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required."
done

kubectl --context "$context" get node >/dev/null

docker image inspect "$image_ref" >/dev/null 2>&1 || fail "Local image $image_ref does not exist. Build it from platform-app first."
kind get clusters | grep -Fx "$kind_cluster" >/dev/null || fail "Kind cluster $kind_cluster does not exist. Follow docs/runbooks/dev-bootstrap.md first."

kind load docker-image "$image_ref" --name "$kind_cluster"
kubectl --context "$context" apply -k clusters/dev/flux-system
kubectl --context "$context" rollout status deployment/source-controller -n flux-system --timeout=120s
kubectl --context "$context" rollout status deployment/kustomize-controller -n flux-system --timeout=120s

flux check --context "$context" --timeout 2m
flux reconcile source git flux-system --context "$context" -n flux-system --timeout 2m
flux reconcile kustomization flux-system --context "$context" -n flux-system --with-source --timeout 2m
flux reconcile kustomization signalboard --context "$context" -n flux-system --with-source --timeout 2m

printf 'Flux bootstrap and Signalboard reconciliation completed. Run scripts/verify-phase2-delivery.sh next.\n'

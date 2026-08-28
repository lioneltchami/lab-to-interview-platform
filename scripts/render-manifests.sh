#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Manifest validation failed: %s\n' "$1" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required to render Kustomize configuration.'
expected_version="${SIGNALBOARD_VERSION:-0.1.0-dev}"

signalboard_output="$(mktemp)"
cluster_output="$(mktemp)"
cleanup() {
  rm -f "$signalboard_output" "$cluster_output"
}
trap cleanup EXIT

kubectl kustomize apps/overlays/dev > "$signalboard_output"
kubectl kustomize clusters/dev > "$cluster_output"

for kind in Namespace ServiceAccount ConfigMap Deployment Service; do
  grep -q "^kind: ${kind}$" "$signalboard_output" || fail "Signalboard overlay does not render a ${kind}."
done

grep -q "^        image: signalboard:${expected_version}$" "$signalboard_output" || fail "Signalboard overlay does not render the expected local development image ${expected_version}."
grep -q '^        runAsNonRoot: true$' "$signalboard_output" || fail 'Signalboard deployment does not enforce a non-root pod security context.'
grep -q '^          allowPrivilegeEscalation: false$' "$signalboard_output" || fail 'Signalboard deployment does not disable privilege escalation.'
grep -q '^          readOnlyRootFilesystem: true$' "$signalboard_output" || fail 'Signalboard deployment does not use a read-only root filesystem.'
grep -q '^      automountServiceAccountToken: false$' "$signalboard_output" || fail 'Signalboard deployment does not disable service-account token mounting.'
grep -q '^  name: flux-system$' "$cluster_output" || fail 'Development cluster configuration does not include the Flux system namespace.'
grep -q '^kind: GitRepository$' "$cluster_output" || fail 'Development cluster configuration does not include a Flux GitRepository.'
grep -q '^kind: Kustomization$' "$cluster_output" || fail 'Development cluster configuration does not include Flux Kustomization resources.'
grep -q '^  name: signalboard$' "$cluster_output" || fail 'Development cluster configuration does not include the Signalboard reconciliation resource.'

printf 'Signalboard and development-cluster Kustomize renders passed policy checks.\n'

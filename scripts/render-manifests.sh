#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Manifest validation failed: %s\n' "$1" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required to render Kustomize configuration.'
declared_version="$(awk '/^[[:space:]]*newTag:[[:space:]]*/ { print $2; exit }' apps/overlays/dev/kustomization.yaml)"
expected_version="${SIGNALBOARD_VERSION:-$declared_version}"
[[ -n "$expected_version" ]] || fail 'Signalboard development image tag is not declared in the overlay.'

signalboard_output="$(mktemp)"
cluster_output="$(mktemp)"
cleanup() {
  rm -f "$signalboard_output" "$cluster_output"
}
trap cleanup EXIT

kubectl kustomize apps/overlays/dev > "$signalboard_output"
kubectl kustomize clusters/dev > "$cluster_output"

for kind in Namespace ServiceAccount ConfigMap Deployment Service NetworkPolicy; do
  grep -q "^kind: ${kind}$" "$signalboard_output" || fail "Signalboard overlay does not render a ${kind}."
done

grep -q "^        image: signalboard:${expected_version}$" "$signalboard_output" || fail "Signalboard overlay does not render the expected local development image ${expected_version}."
grep -q '^        runAsNonRoot: true$' "$signalboard_output" || fail 'Signalboard deployment does not enforce a non-root pod security context.'
grep -q '^          allowPrivilegeEscalation: false$' "$signalboard_output" || fail 'Signalboard deployment does not disable privilege escalation.'
grep -q '^          readOnlyRootFilesystem: true$' "$signalboard_output" || fail 'Signalboard deployment does not use a read-only root filesystem.'
grep -q '^      automountServiceAccountToken: false$' "$signalboard_output" || fail 'Signalboard deployment does not disable service-account token mounting.'
grep -q '^    pod-security.kubernetes.io/enforce: restricted$' "$signalboard_output" || fail 'Signalboard namespace does not enforce the restricted Pod Security Standard.'
grep -q '^    pod-security.kubernetes.io/audit: restricted$' "$signalboard_output" || fail 'Signalboard namespace does not audit the restricted Pod Security Standard.'
grep -q '^    pod-security.kubernetes.io/warn: restricted$' "$signalboard_output" || fail 'Signalboard namespace does not warn for the restricted Pod Security Standard.'
grep -q '^  name: signalboard-default-deny$' "$signalboard_output" || fail 'Signalboard default-deny NetworkPolicy is not rendered.'
grep -q '^  - Ingress$' "$signalboard_output" || fail 'Signalboard NetworkPolicy does not select ingress isolation.'
grep -q '^  - Egress$' "$signalboard_output" || fail 'Signalboard NetworkPolicy does not select egress isolation.'
grep -q '^  name: flux-system$' "$cluster_output" || fail 'Development cluster configuration does not include the Flux system namespace.'
grep -q '^kind: GitRepository$' "$cluster_output" || fail 'Development cluster configuration does not include a Flux GitRepository.'
grep -q '^kind: Kustomization$' "$cluster_output" || fail 'Development cluster configuration does not include Flux Kustomization resources.'
grep -q '^  name: signalboard$' "$cluster_output" || fail 'Development cluster configuration does not include the Signalboard reconciliation resource.'

printf 'Signalboard and development-cluster Kustomize renders passed policy checks.\n'

#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'D1 pre-bootstrap validation failed: %s\n' "$1" >&2
  exit 1
}

required_files=(
  'docs/decisions/0007-durable-platform-availability.md'
  'docs/decisions/0008-private-access-and-traffic-management.md'
  'docs/decisions/0009-d1-initial-platform-selection.md'
  'docs/phase-3-durable-platform.md'
  'docs/hardware-inventory-template.md'
  'docs/runbooks/phase-3-durable-bootstrap.md'
  'talos/README.md'
  'talos/d1/README.md'
  'talos/d1/bootstrap-input.example.yaml'
  'talos/patches/cni-none.example.yaml'
  'apps/base/signalboard/network-policy.yaml'
  'tests/policy/verify-signalboard-pod-security.sh'
)

for required_file in "${required_files[@]}"; do
  [[ -f "$required_file" ]] || fail "Missing required D1 artifact: ${required_file}."
done

grep -q '^    claim: single-control-plane-durable-learning-environment$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not declare the approved single-control-plane claim.'
grep -q '^    publicExposureAllowed: false$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not prohibit public exposure by default.'
grep -q '^    remoteAccessEnabled: false$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not defer remote access.'
grep -q '^    generatedCredentialsStoredOutsideGit: true$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not keep generated credentials outside Git.'
grep -q '^    signalboardPodSecurity: restricted$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not retain the Signalboard Pod Security baseline.'
grep -q '^    signalboardNetworkPolicy: declared-default-deny$' talos/d1/bootstrap-input.example.yaml || fail 'D1 template does not retain the default-deny policy boundary.'

for private_path in talos/generated/secrets.yaml talos/private/talosconfig talos/d1/kubeconfig; do
  git check-ignore -q "$private_path" || fail "Generated private path is not ignored: ${private_path}."
done

if git ls-files | grep -E '(^|/)(secrets\.yaml|talosconfig|kubeconfig(\.|$)|.*\.key$|.*\.pem$)' >/dev/null; then
  fail 'A credential-shaped Talos bootstrap artifact is tracked by Git.'
fi

command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required to render the policy foundation.'
kubectl kustomize apps/overlays/dev >/dev/null

printf 'D1 pre-bootstrap template, policy, and secret-boundary checks passed.\n'

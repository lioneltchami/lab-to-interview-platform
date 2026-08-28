#!/usr/bin/env bash
set -euo pipefail

context="${KUBE_CONTEXT:-kind-lab-to-interview-dev}"
namespace="signalboard"

fail() {
  printf 'Pod Security verification failed: %s\n' "$1" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || fail 'kubectl is required.'
kubectl --context "$context" get namespace "$namespace" >/dev/null

for mode in enforce audit warn; do
  actual="$(kubectl --context "$context" get namespace "$namespace" -o "jsonpath={.metadata.labels.pod-security\\.kubernetes\\.io/${mode}}")"
  [[ "$actual" == "restricted" ]] || fail "Expected ${mode}=restricted; found ${actual:-unset}."
done

probe_output="$(mktemp)"
trap 'rm -f "$probe_output"' EXIT

if cat <<'EOF' | kubectl --context "$context" apply --dry-run=server -n "$namespace" -f - >"$probe_output" 2>&1; then
apiVersion: v1
kind: Pod
metadata:
  name: phase-3-pod-security-negative-test
spec:
  containers:
    - name: non-compliant
      image: registry.k8s.io/pause:3.10
      securityContext:
        privileged: true
EOF
  fail 'A deliberately privileged pod was accepted by the restricted namespace.'
fi

grep -qi 'violates PodSecurity' "$probe_output" || fail 'The rejected probe did not report a Pod Security violation.'
printf 'Restricted Pod Security admission verified for namespace %s.\n' "$namespace"

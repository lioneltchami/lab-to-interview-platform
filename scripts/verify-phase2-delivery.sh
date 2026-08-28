#!/usr/bin/env bash
set -euo pipefail

context="${KUBE_CONTEXT:-kind-lab-to-interview-dev}"
expected_version="${EXPECTED_VERSION:-0.1.0-dev}"
expected_marker="${EXPECTED_RELEASE_MARKER:-}"
local_port="${SIGNALBOARD_LOCAL_PORT:-18081}"
log_file="$(mktemp)"
port_forward_pid=""

fail() {
  printf 'Phase 2 delivery verification failed: %s\n' "$1" >&2
  exit 1
}

cleanup() {
  if [[ -n "$port_forward_pid" ]] && kill -0 "$port_forward_pid" >/dev/null 2>&1; then
    kill "$port_forward_pid" >/dev/null 2>&1 || true
    wait "$port_forward_pid" 2>/dev/null || true
  fi
  rm -f "$log_file"
}
trap cleanup EXIT

for command in kubectl flux curl; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required."
done

flux check --context "$context" --timeout 2m
kubectl --context "$context" wait --for=condition=Ready gitrepository/flux-system -n flux-system --timeout=120s
kubectl --context "$context" wait --for=condition=Ready kustomization/flux-system -n flux-system --timeout=120s
kubectl --context "$context" wait --for=condition=Ready kustomization/signalboard -n flux-system --timeout=120s
kubectl --context "$context" rollout status deployment/signalboard -n signalboard --timeout=120s

service_type="$(kubectl --context "$context" get service/signalboard -n signalboard -o jsonpath='{.spec.type}')"
[[ "$service_type" == 'ClusterIP' ]] || fail "Signalboard service type is $service_type, expected ClusterIP."

if kubectl --context "$context" get ingress -n signalboard --no-headers 2>/dev/null | grep -q .; then
  fail 'Signalboard namespace contains an Ingress, but Phase 2 requires no public route.'
fi

kubectl --context "$context" port-forward -n signalboard service/signalboard "${local_port}:80" > "$log_file" 2>&1 &
port_forward_pid=$!

ready=''
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if ready="$(curl --silent --fail "http://127.0.0.1:${local_port}/health/ready" 2>/dev/null)"; then
    break
  fi
  sleep 1
done
[[ -n "$ready" ]] || { cat "$log_file" >&2; fail 'Signalboard readiness endpoint did not respond through the internal ClusterIP service.'; }

version="$(curl --silent --show-error --fail "http://127.0.0.1:${local_port}/api/v1/version")"
printf '%s' "$ready" | grep -q '"status":"ready"' || fail 'Readiness endpoint did not return the expected ready status.'
printf '%s' "$version" | grep -q "\"version\":\"${expected_version}\"" || fail "Version endpoint did not return ${expected_version}."
if [[ -n "$expected_marker" ]]; then
  status="$(curl --silent --show-error --fail "http://127.0.0.1:${local_port}/api/v1/status")"
  printf '%s' "$status" | grep -q "\"marker\":\"${expected_marker}\"" || fail "Status endpoint did not return source marker ${expected_marker}."
fi

log_output="$(kubectl --context "$context" logs deployment/signalboard -n signalboard --tail=20)"
case "$log_output" in
  *'"event":"http_request"'*) ;;
  *) fail 'Signalboard did not emit a structured request log after verification.' ;;
esac

printf 'Flux source, Flux Kustomizations, Signalboard rollout, internal service access, version, optional source marker, structured logs, and private-only service checks passed.\n'

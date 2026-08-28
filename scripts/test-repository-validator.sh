#!/usr/bin/env bash
set -euo pipefail

probe_file="tests/validator-secret-probe.txt"
cleanup() {
  rm -f "$probe_file"
}
trap cleanup EXIT

printf '%s%s\n' 'github_pat_' '0123456789abcdefghijklmnop' > "$probe_file"

if bash scripts/validate-repository.sh >/tmp/lab-to-interview-validator-test.log 2>&1; then
  cat /tmp/lab-to-interview-validator-test.log >&2
  printf 'Validator test failed: a credential-shaped probe did not cause validation to fail.\n' >&2
  exit 1
fi

if ! grep -q 'likely live credential' /tmp/lab-to-interview-validator-test.log; then
  cat /tmp/lab-to-interview-validator-test.log >&2
  printf 'Validator test failed: the expected credential detection result was not recorded.\n' >&2
  exit 1
fi

printf 'Validator negative test passed.\n'
cleanup
trap - EXIT
bash scripts/validate-repository.sh

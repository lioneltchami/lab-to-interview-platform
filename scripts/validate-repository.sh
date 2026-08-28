#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'Repository validation failed: %s\n' "$1" >&2
  exit 1
}

required_files=(
  "README.md"
  "docs/project-brief.md"
  "docs/product-brief.md"
  "docs/evidence/index.md"
  "docs/runbooks/dev-bootstrap.md"
  "docs/security/data-classification.md"
  "docs/decisions/0001-reference-archive-boundary.md"
  "docs/decisions/0002-canonical-git-source.md"
  "docs/decisions/0003-gitops-controller.md"
  "docs/decisions/0004-durable-node-platform.md"
  "docs/decisions/0005-secret-management-baseline.md"
  "docs/decisions/0006-private-by-default-exposure.md"
  ".github/pull_request_template.md"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || fail "required file is missing: $file"
done

if git diff --check; then
  printf 'Whitespace check passed.\n'
else
  fail 'Git detected whitespace errors.'
fi

candidate_file_list="$(mktemp)"
cleanup() {
  rm -f "$candidate_file_list"
}
trap cleanup EXIT

git ls-files --cached --others --exclude-standard > "$candidate_file_list"

if [[ ! -s "$candidate_file_list" ]]; then
  fail 'no repository files are available for validation.'
fi

while IFS= read -r file; do
  case "$file" in
    .gitignore|tests/fixtures/*)
      continue
      ;;
  esac

  case "$file" in
    mischavandenburg-homelab-main|mischavandenburg-homelab-main.zip|reference-archive/*)
      fail "historical archive content is tracked or unignored: $file"
      ;;
  esac

  case "$file" in
    .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.kubeconfig|*/kubeconfig|*/talosconfig|age.key|age-key.txt|keys.txt|*.agekey)
      fail "restricted credential or local configuration file is available for commit: $file"
      ;;
  esac
done < "$candidate_file_list"

secret_pattern='-----BEGIN ([A-Z ]+)?PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}'
legacy_owner='mischavandenburg'
legacy_pattern="ssh://git@github\\.com/${legacy_owner}/|${legacy_owner}/homelab"

while IFS= read -r file; do
  case "$file" in
    .gitignore|tests/fixtures/*)
      continue
      ;;
  esac

  if grep -nI -E -e "$secret_pattern" -- "$file" >/dev/null 2>&1; then
    grep -nI -E -e "$secret_pattern" -- "$file" >&2 || true
    fail "likely live credential or private-key marker appears in $file"
  fi

  if grep -nI -E "$legacy_pattern" -- "$file" >/dev/null 2>&1; then
    grep -nI -E "$legacy_pattern" -- "$file" >&2 || true
    fail "legacy repository reference appears in $file"
  fi
done < "$candidate_file_list"

printf 'Required-document, archive-boundary, and basic secret-pattern checks passed.\n'

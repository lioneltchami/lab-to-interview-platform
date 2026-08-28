# Data Classification and Public-Sharing Rules

**Status:** Active Phase 1 policy
**Owner:** Repository maintainer
**Review trigger:** Any proposed public release, screenshot, video, issue, pull request, demo, teaching asset, integration, or new data source.

## Purpose

Lab to Interview will create technical evidence that others can read and learn from. Evidence remains valuable only when it protects private systems and accurately represents the work. This policy classifies project information, defines approved storage locations, and sets a public-sharing review process.

## Classification model

| Classification | Examples | Approved storage | Public sharing rule |
|---|---|---|---|
| **Public** | Original documentation, sanitized diagrams, source code with no sensitive configuration, synthetic test data, public release notes, approved screenshots. | Canonical repository after review. | Share only after the maintainer confirms it contains no restricted or confidential detail. |
| **Internal project** | Draft ADRs, implementation ideas, unreviewed issue discussions, non-sensitive local environment notes. | Private repository and private planning folders. | Do not publish until reviewed and reclassified. |
| **Confidential** | Private repository URLs, personal email addresses, service configuration that reveals deployment structure, internal test recordings, unpublished learning materials. | Private repository or approved private storage. | Share only with named collaborators who need it. Redact before public use. |
| **Restricted** | Passwords, tokens, private keys, recovery codes, kubeconfigs, SOPS age keys, cloud credentials, Talos secrets, unredacted internal IPs, home addresses, router configuration, raw personal data, security incidents with exploit details. | Password manager, approved secret store, encrypted local storage, or service-specific secure configuration. | Never commit, attach, paste into chat, include in screenshots, or publish. Rotate if exposed. |

## Required handling rules

| Situation | Required action |
|---|---|
| Adding a configuration file | Confirm that it uses a placeholder or encrypted value. Add a safe fixture if tests need a representative example. |
| Sharing terminal output | Remove usernames, tokens, paths that reveal private identity, IP addresses, internal hostnames, certificate data, and command history containing secrets. |
| Recording a demonstration | Use synthetic data and a prepared browser profile. Hide notifications, bookmarks, account identities, internal URLs, and password-manager prompts. |
| Creating a diagram | Use logical service names and generic network boundaries. Do not include home address, ISP information, device serial numbers, public IP addresses, or real credentials. |
| Opening an issue or pull request | Classify the attachment and link only sanitized evidence. Put sensitive investigation details in an approved private location. |
| Receiving a suspected secret | Remove it from the working tree, revoke or rotate it at its provider, inspect history and logs, and record the remediation without reproducing the secret. |
| Publishing a lesson | Verify technical version, authorship, screenshots, citations, command safety, and redaction before release. |

## Repository rules

1. Never commit `.env` files, private keys, certificates, kubeconfigs, passwords, access tokens, generated cluster secrets, raw backups, package caches, or local machine metadata.
2. Use synthetic fixtures with clearly impossible values such as `example.invalid`, `REPLACE_ME`, or `not-a-real-secret` for tests and documentation.
3. Keep secret material and decryption keys outside the repository. Add encrypted material only after a documented secret-management workflow exists.
4. Do not add source archives, screenshots, videos, or documents from third parties unless you have a clear right to store and share them.
5. Treat the historical homelab archive as restricted reference material. It is excluded from this repository by ADR 0001.
6. Do not claim that an artifact is public, production-ready, highly available, secure, or recovered unless the linked evidence supports that claim.

## Public-release checklist

A maintainer must answer every item before changing a file, release, repository, issue, or demonstration from private to public.

| Review item | Required answer |
|---|---|
| Authorship | Is the code, document, diagram, recording, or image original or correctly attributed and licensed? |
| Secrets | Has the artifact been scanned and manually checked for tokens, keys, credentials, private URLs, and configuration values? |
| Network privacy | Does it hide public IPs, internal IP ranges, domain-management data, home locations, hostnames, and network topology that should remain private? |
| Personal privacy | Does it hide personal email, account identifiers, device data, notifications, browsing data, and third-party personal information? |
| Operational safety | Does it avoid showing a live administrative session, control-plane access path, or a bypassable security configuration? |
| Claim accuracy | Does every reliability, security, performance, or career statement link to evidence or remain clearly framed as a goal? |
| Data license | Do you have permission to share every screenshot, log, dataset, diagram asset, recording, and third-party dependency reference? |
| Future reversibility | Can you remove or rotate the exposed material if the sharing decision changes? |

## Incident response for accidental exposure

1. Stop further sharing and remove public access where possible.
2. Revoke or rotate the exposed secret or credential at its source.
3. Remove the value from the working tree, issues, artifacts, and logs under your control.
4. Inspect repository and deployment history to identify copies or downstream use.
5. Record the incident as restricted internal documentation without repeating the secret.
6. Improve the ignore rules, scanning, review checklist, or training material that should have prevented the exposure.

## Related documents

- [`ADR 0001`](../decisions/0001-reference-archive-boundary.md)
- [`ADR 0005`](../decisions/0005-secret-management-baseline.md)
- [`Evidence Index`](../evidence/index.md)
- [`Pull Request Template`](../../.github/pull_request_template.md)

# ADR 0001: Quarantine the Historical Homelab Archive

**Status:** Accepted
**Date:** 2026-08-28
**Decision owner:** Repository maintainer

## Context

The project review included a historical homelab repository archive from a third party. The archive contains useful architectural patterns, including GitOps layering, environment overlays, platform services, monitoring, and stateful workloads. It also contains incomplete dependencies, inaccessible repository remotes, version drift, and sensitive-looking historical configuration references.

Lab to Interview must remain original, safe to share, and straightforward to explain. The project must not depend on unpublished third-party material, past secrets, hard-coded network settings, unknown private repositories, or copied implementation identity.

## Decision

The historical archive remains a **private reference only**. The Lab to Interview repository will not copy its source files, remotes, names, credentials, personal network values, application bundle, branding, screenshots, or documentation text.

The repository may use generalized lessons learned from the review. A decision record or design note must state the new project’s own context, alternatives, trade-offs, and validation plan. The maintainer must write all manifests, automation, diagrams, code, teaching material, and public copy as original work.

## Consequences

| Positive consequence | Cost or constraint |
|---|---|
| The public project has a clear authorship and security boundary. | The team must recreate useful structures from first principles rather than quickly transplanting configuration. |
| The platform avoids stale, incomplete, or unsafe dependencies. | Some early implementation choices require more explicit research and validation. |
| The project can teach ethical reference use and reproducible engineering practice. | The archive remains unavailable as an executable shortcut. |
| The repository’s evidence reflects the maintainer’s own decisions. | The maintainer must document assumptions and test results carefully. |

## Rules

1. Do not add the historical archive or any extraction of it to this repository.
2. Do not reuse any credential, key, token, certificate, IP address, hostname, Wi-Fi information, or repository remote found in the archive.
3. Do not copy manifests, application configuration, README text, course materials, screenshots, brand terms, or service selections from the archive.
4. Document external tools through official links, version references, and project-specific design decisions.
5. If a future contribution resembles a reference implementation, the contributor must explain the original requirement, changes made, and independent validation.
6. Store the archive only in the separate private research folder. Do not attach it to public issues, pull requests, releases, demonstrations, or teaching packages.

## Verification

| Check | Pass condition |
|---|---|
| Repository search | No historical archive file, original owner name, third-party remote URL, or extracted configuration appears in tracked content. |
| Secret scan | No credential, private key, kubeconfig, access token, or network-specific secret appears in tracked content. |
| Authorship review | New design records state the project’s own decision and validation plan. |
| Public-release review | A maintainer confirms that public artifacts use sanitized, original content. |

## Rejected alternatives

| Alternative | Reason for rejection |
|---|---|
| Deploy the archive unchanged. | The snapshot is incomplete and uses outdated or unavailable dependencies. It would not provide an original, reproducible build. |
| Copy portions and edit later. | This blurs authorship, increases the chance of inheriting sensitive data, and makes review difficult. |
| Publish the archive as a learning reference. | The archive may contain material that must remain private and its sources or licenses cannot be treated as cleared for redistribution. |

# ADR 0005: Use an Encrypted-Secret Baseline and Defer Live Secrets

**Status:** Accepted
**Date:** 2026-08-28
**Decision owner:** Repository maintainer
**Review trigger:** Before the first secret resource, before a cloud integration, or when the project’s audience or threat model changes.

## Context

The project will later need credentials for GitOps bootstrap, application configuration, container registries, domains, and possibly cloud services. The historical archive review showed why a repository must not treat credentials or private configuration as ordinary documentation.

Phase 1 does not require a live secret. Adding real secrets before the local delivery path and public/private boundary are proven would create risk without advancing the learning outcome.

## Decision

Phase 1 will commit **no live secret values**. The project will establish an encrypted-secret baseline and document the intended operating model. The leading implementation is SOPS with Age for the first self-contained GitOps path, with a cloud key-management service as a later alternative if the target learning goal requires it.

The project will store encrypted secret resources only after the maintainer creates separate decryption-key custody, access, backup, rotation, and recovery procedures. No key, token, kubeconfig, private certificate, or unencrypted `.env` file may be tracked.

## Decision criteria

| Criterion | Requirement | Validation |
|---|---|---|
| No plaintext credentials | Git history and repository artifacts contain no live secret values. | Automated secret scan and manual review pass. |
| Separation of duties | Encrypted ciphertext and decryption keys have separate storage and access paths. | Security documentation maps both locations without exposing them. |
| Reproducibility | An authorized maintainer can restore the secret workflow through a documented process. | Later clean-bootstrap and recovery test succeeds without committing keys. |
| Least privilege | Applications and automation receive only the credentials required for their own actions. | Access matrix and service-account configuration show the boundary. |
| Teachability | A learner can understand the model without receiving a reusable real credential. | Lesson includes synthetic examples and a redaction checklist. |

## Consequences

| Benefit | Cost or limitation | Mitigation |
|---|---|---|
| The project can be shared without embedding credentials in source control. | Initial setup requires separate key custody and documentation. | Build the procedure before introducing a live secret. |
| Secret rotation and recovery become explicit operational work. | The first encryption workflow adds learning overhead. | Begin with a small synthetic example in a disposable environment. |
| The design can later support either local Age keys or cloud key management. | The project must choose and document one implementation before deployment. | Create a follow-up ADR when cloud identity or hardware constraints are known. |

## Security and privacy impact

This ADR establishes a strict rule: only sanitized examples, empty placeholders, and encrypted non-live fixtures may be tracked. Local developer files and decryption material remain untracked. A compromised historical value must be rotated at its original service before any reference is used.

## Validation plan

| Test or observation | Pass condition | Evidence location |
|---|---|---|
| Ignore rules | Local `.env`, key, certificate, token, and kubeconfig patterns are excluded. | `.gitignore` and test fixture review. |
| Secret scan | An intentional harmless test token pattern triggers the scanner; the repository baseline contains no finding. | CI workflow output. |
| Documentation | The data classification and key-custody sections identify what is public, encrypted, and private. | `docs/security/data-classification.md`. |
| Later encryption test | An authorized test environment decrypts only intended synthetic configuration. | Phase 3 evidence record. |

## Alternatives considered

| Alternative | Strength | Reason not selected now |
|---|---|---|
| Commit plain Kubernetes Secret manifests. | Fast local setup. | It creates a high-risk sharing and rotation model. |
| Adopt a cloud secret store immediately. | Demonstrates cloud identity and centralized key management. | It introduces account, billing, identity, and integration work before the core delivery path is proven. |
| Use one shared local `.env` file. | Familiar for application development. | It does not scale to GitOps or provide safe source-control boundaries. |

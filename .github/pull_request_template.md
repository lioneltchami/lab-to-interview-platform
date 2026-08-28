# Pull Request

## Purpose

Explain the problem this change solves and the intended system behavior. Link the issue, decision record, evidence item, or runbook section that gives the change context.

## Change summary

Describe the changed files and the design decision. State whether the change affects application behavior, cluster configuration, delivery, security, telemetry, backups, teaching material, or public-facing documentation.

## Verification

- [ ] I ran the relevant local checks and recorded the result below.
- [ ] I rendered or validated the affected manifests, documentation, code, or configuration.
- [ ] I tested the expected behavior and one relevant failure or negative path where applicable.
- [ ] I updated the runbook, decision record, evidence index, or lesson material when this change altered documented behavior.

**Verification evidence:**

```text
Command, test, workflow, dashboard, or evidence link:
Observed result:
Known limitation:
```

## Security and privacy review

- [ ] This change contains no password, private key, token, kubeconfig, certificate, live credential, secret value, or unencrypted sensitive configuration.
- [ ] This change contains no private address, internal hostname, personal data, home-network detail, browser data, or third-party confidential material.
- [ ] I reviewed generated and copied files, not only handwritten source.
- [ ] Any new identity, privilege, network route, secret, persistent data, or public endpoint is documented in an ADR or security note.
- [ ] Any image, dependency, or external action has an explicit version or immutable reference appropriate to the change.

## Evidence and sharing classification

- [ ] I added or updated an item in `docs/evidence/index.md` when this change proves a capability.
- [ ] I classified screenshots, recordings, logs, and generated artifacts before attaching them.
- [ ] I made no unsupported availability, security, performance, career, or production-readiness claim.

**Classification:** Public | Internal project | Confidential | Restricted

## Review request

State the exact decision, risk, or verification result that you want a reviewer to check. Do not ask for a general “looks good” review.

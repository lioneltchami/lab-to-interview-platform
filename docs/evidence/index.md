# Evidence Index

**Status:** Active Phase 1 baseline
**Purpose:** Keep the Lab to Interview platform honest, reviewable, and teachable by linking each material claim to an artifact that someone can inspect.

## How to use this index

Add evidence when a phase task is complete. Do not mark a capability complete because a component exists. Mark it complete only when you can show a test, observation, documented procedure, or reviewed outcome. Classify every artifact before sharing under the [data-classification policy](../security/data-classification.md).

| State | Meaning |
|---|---|
| Planned | The project intends to produce this artifact, but no verified result exists. |
| Draft | A document, test, or configuration exists but has not passed the stated validation. |
| Verified | The stated pass condition was met and the evidence link or location is recorded. |
| Superseded | Newer evidence or design replaced this item; retain a link to the replacement. |

## Evidence register

| ID | Phase | Claim or capability | Required evidence | Status | Classification | Owner |
|---|---|---|---|---|---|---|
| E-001 | 1 | The project has an original, bounded purpose. | Project brief, product brief, and first architecture decisions. | Verified | Internal project | Repository maintainer |
| E-002 | 1 | The historical archive cannot leak into the new project. | Archive-boundary ADR, ignore rules, secret scan, and manual repository review. | Verified | Confidential | Repository maintainer |
| E-003 | 1 | A fresh development baseline can be created and deleted. | Dated bootstrap log, local cluster health output, deletion log, and runbook revision. | Verified | Internal project | Repository maintainer |
| E-004 | 1 | Repository checks catch basic hygiene failures. | CI run for normal content plus controlled negative fixtures. | Draft — local negative and clean checks passed; remote CI verification follows the initial push. | Internal project | Repository maintainer |
| E-005 | 2 | A code change reaches the development cluster from Git. | Pull request, CI record, image digest, Flux status, and application version endpoint. | Planned | Public after review | Repository maintainer |
| E-006 | 2 | The deployment can roll back. | Rollback runbook, Git revision, health output, and elapsed time. | Planned | Public after review | Repository maintainer |
| E-007 | 3 | The durable platform has documented topology and access boundaries. | Hardware inventory, architecture diagram, topology tests, and access runbook. | Planned | Confidential with public summary | Repository maintainer |
| E-008 | 3 | Network policy prevents unintended connections. | Default-deny policy, connectivity test output, and policy report. | Planned | Public after review | Repository maintainer |
| E-009 | 3 | Secret handling separates ciphertext from keys and avoids plaintext Git history. | Secret-management ADR, redacted configuration, scan result, and authorized bootstrap test. | Planned | Confidential with public summary | Repository maintainer |
| E-010 | 4 | Service behavior is observable. | SLI/SLO document, dashboard export, log example, alert configuration, and test alert. | Planned | Public after review | Repository maintainer |
| E-011 | 4 | The platform handles a controlled incident. | Scenario, detection signal, timeline, remediation pull request, and post-incident review. | Planned | Public after review | Repository maintainer |
| E-012 | 4 | Persistent state can be restored to a tested target. | Recovery contract, backup record, restore report, validation output, elapsed time, and limitations. | Planned | Confidential with public summary | Repository maintainer |
| E-013 | 5 | An interviewer can understand the system and decisions quickly. | Public README, architecture case study, five-minute overview, and technical deep-dive outline. | Planned | Public | Repository maintainer |
| E-014 | 5 | A learner can reproduce a bounded part of the work. | Versioned lesson, prerequisites, build steps, verification, failure exercise, and reflection prompt. | Planned | Public after review | Repository maintainer |

## Evidence capture record

Copy the following table into a phase-specific evidence note when you complete an item.

| Field | Record |
|---|---|
| Evidence ID | `E-XXX` |
| Date and timezone | `YYYY-MM-DD HH:MM TZ` |
| Component and version | Name, version, image digest, and relevant repository revision. |
| Environment | Development, staging, production-shaped, or recovery target. Do not include private network details. |
| Change or scenario | What you changed, tested, or observed. |
| Expected result | The pre-defined pass condition. |
| Actual result | Observed behavior and elapsed time where relevant. |
| Evidence links | Pull request, workflow, test output, dashboard export, sanitized screenshot, or runbook. |
| Classification | Public, internal project, confidential, or restricted. |
| Limitations | What this evidence does not prove. |
| Reviewer | Name or role, if a review occurred. |
| Follow-up | Issue, ADR, remediation, or next review date. |

## Publication rules

A public evidence item must link to original, sanitized artifacts only. A public dashboard image should show synthetic values and hide internal URLs, service-account names, user data, notification content, and browser profile information. A public recovery report should describe scope, target, elapsed time, and limits without disclosing the source or destination credential paths.

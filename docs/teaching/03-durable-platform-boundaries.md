# Phase 3 Teaching Pack: Durable Platform Boundaries

**Status:** Original teaching outline
**Audience:** Learners who have completed the Phase 1 scope exercise and the Phase 2 GitOps delivery exercise
**Promise:** Learners can distinguish a disposable Kubernetes environment from a durable platform, name the security boundaries that matter, and prove one policy claim with evidence.

## Teaching philosophy

This pack does not ask learners to buy hardware, run an identity provider, expose a website, or collect a large toolset. It asks them to make a specific operational claim, document its limits, choose a control that supports the claim, and capture evidence. That is the transferable engineering skill.

## Unit 1: Infrastructure as a Rebuildable System

| Section | Content |
|---|---|
| Learning promise | The learner can select an availability profile that matches real hardware and describe its limits accurately. |
| Starting state | A public GitOps repository and a disposable development cluster exist. No durable-node configuration or private credentials are committed. |
| Scenario | The learner is asked to move a proven service to “production.” The available hardware is unclear and a teammate suggests calling two nodes “highly available.” |
| Build task | Complete a sanitized hardware inventory, compare D1 and D2 profiles, write an ADR with both claims and non-claims, and draw a topology that contains no sensitive addresses. |
| Verification | A reviewer can identify the chosen profile, the API-endpoint expectation, the control-plane count, and the reason no HA claim is made. |
| Evidence artifact | Sanitized inventory summary, availability ADR, and topology diagram. |
| Failure mode | A machine is reimaged without authorization or configuration is generated with guessed disk and interface values. |
| Interview bridge | “Why did you start with one durable control plane rather than three, and what evidence would you need before changing that answer?” |

## Unit 2: Network Policy as an Executable Diagram

| Section | Content |
|---|---|
| Learning promise | The learner can convert an application traffic boundary into a standard Kubernetes NetworkPolicy and a test plan. |
| Starting state | Signalboard has a dedicated namespace and ClusterIP Service. A CNI enforcement choice has not yet been deployed. |
| Scenario | A team wants a default-deny policy but also needs a future controlled path from a named gateway or client. |
| Build task | Declare a standard default-deny policy, write the intended allowed path in plain language, then add the smallest allow rule only after the caller exists. |
| Verification | On a Cilium-enabled cluster, an unauthorized request fails and the specifically authorized request succeeds. Removing the allow rule returns the system to denial. |
| Evidence artifact | Policy manifest, topology diagram, allowed/denied test output, and a brief explanation of the CNI’s enforcement role. |
| Failure mode | Deleting the default-deny policy during troubleshooting or using multiple policy formats with unclear interaction. |
| Interview bridge | “How did you prove that this policy was enforced rather than merely committed to Git?” |

## Unit 3: Secrets Without Mystery

| Section | Content |
|---|---|
| Learning promise | The learner can explain the difference between a public configuration repository, encrypted secret ciphertext, and decryption-key custody. |
| Starting state | Repository secret scanning and push protection are enabled. The project contains no real application secret. |
| Scenario | A service needs its first secret, and someone proposes committing an `.env` file “just for the lab.” |
| Build task | Identify the secret owner, rotation event, bootstrap path, recovery path, and public-sharing boundary before selecting SOPS with Age or a cloud KMS. |
| Verification | A review finds no plaintext value, no private decryption key, and no invented placeholder treated as a production secret. |
| Evidence artifact | Secret-management ADR, access matrix, redacted bootstrap verification, and provider scan result. |
| Failure mode | Treating encrypted data as safe while storing the decryption key in the same repository or a public CI log. |
| Interview bridge | “What would happen if your Git repository were public, your decryption key were lost, or a maintainer needed emergency access?” |

## Facilitator checklist

Before running these exercises, confirm that learners understand the difference between development proof and availability claims, are using sanitized example data, do not share device or network details in public evidence, and may stop at the planning boundary if they do not own reimageable hardware. Assess decisions and evidence, not the number of installed tools.

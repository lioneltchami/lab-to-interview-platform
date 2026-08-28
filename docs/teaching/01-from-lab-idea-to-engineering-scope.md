# Lesson 01: From Lab Idea to Engineering Scope

**Learning promise:** You will turn a technical reference into an original, bounded project with a clear safety boundary, decision record, definition of done, and evidence plan.

## Scenario

You found an interesting homelab or platform project online. It contains enough tools to feel impressive, but you cannot yet explain which parts solve your problem, which parts you can safely operate, or how a hiring manager would understand your work. You need to create your own engineering scope before you create infrastructure.

## Prerequisites

| Requirement | Why it matters |
|---|---|
| A project folder and new Git repository. | You need an original source of truth for your own work. |
| A reference project or idea. | Use it for patterns and questions, not for copied files or credentials. |
| The Lab to Interview templates. | They give you a repeatable structure for decisions and evidence. |
| A willingness to keep the first milestone small. | A finished, explainable path teaches more than an unverified tool collection. |

## Starting state

You have a new repository with no live secrets, no copied configuration, no public services, and no claims about reliability or career outcomes. You may have a separate private research folder, but it remains outside your repository history.

## Build steps

### Step 1: Write one sentence that describes the project

Use this pattern:

> “I am building **[a small system]** so that I can demonstrate **[a specific engineering capability]** through **[evidence I can verify]**.”

For this project, the working version is:

> “I am building a small, GitOps-managed application platform so that I can demonstrate delivery, security, observability, and recovery through tested engineering evidence.”

Rewrite the sentence for your own project. Remove any tool name that does not state a capability or evidence outcome.

### Step 2: Define the first user and first service

Name a small, synthetic-data workload. It should exist to exercise the platform, not to become an unrelated product. Define one user journey, one health behavior, and one controlled failure you want to test later.

### Step 3: Separate reference lessons from borrowed material

Create an archive-boundary decision record. State the useful patterns you observed, then name the items that will remain private or excluded: remotes, credentials, configuration, code, documentation text, branding, screenshots, and personal details.

### Step 4: Choose only the first technical milestone

Choose a disposable local development environment before durable hardware. The first milestone is not “build a production homelab.” The first milestone is “create, verify, delete, and recreate a local cluster using a written runbook.”

### Step 5: Define evidence before implementation

For each intended claim, name the proof you will save. A delivery claim needs a pull request and deployment record. A security claim needs a policy test. A recovery claim needs a restore report. Add those items to an evidence index before you begin.

### Step 6: Write one decision record

Use the ADR template to record one choice. State the context, selected option, rejected options, consequences, privacy impact, validation plan, and review trigger. A good ADR shows judgment; it does not try to prove that a tool is universally best.

## Verification

| Check | Pass condition |
|---|---|
| Project statement | A reader can identify the system, capability, and evidence without asking follow-up questions. |
| Scope | The first milestone fits in one disposable environment and one short runbook. |
| Originality | The repository contains no copied source, credential, private configuration, or branding from reference material. |
| Evidence | The evidence index lists the artifact that will prove each major future claim. |
| Decision record | One ADR states a decision, an alternative, a trade-off, and a validation plan. |

## Evidence artifact

Save a project brief, product brief, archive-boundary ADR, data-classification policy, evidence index, and a completed development-baseline record. Classify each item before sharing it.

## Common failure mode

**Failure:** You add a long list of tools because they sound enterprise-grade.

**Investigative path:** For each tool, ask which user problem it solves, which test proves it works, what information it stores, who operates it, how it upgrades, and how it recovers. Defer the tool if you cannot answer those questions yet.

## Interview bridge

Practice this answer:

> “I started by constraining the project. I chose one application and one reproducible local environment, then I defined the evidence I would need before I added more infrastructure. That let me show tested decisions rather than a collection of tools.”

## Reflection

How would your choices change if you had only one machine, a strict privacy requirement, a cloud-credit budget, or a team of learners with different levels of prior experience? Record your answer in an ADR or project note.

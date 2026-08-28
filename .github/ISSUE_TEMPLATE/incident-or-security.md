---
name: Incident or security observation
about: Record a sanitized operational incident, security concern, or recovery exercise
title: "incident: "
labels: "incident"
assignees: ""
---

## Safety notice

Do not enter passwords, tokens, private keys, recovery codes, personal data, private addresses, exploit instructions, or other restricted material in this issue. Use the approved private handling path for sensitive details.

## Summary

State the observable symptom, affected component, environment classification, and time window. Use synthetic or redacted identifiers.

## Impact

Describe what the system or learner experienced. State what this incident does and does not prove about availability, security, or recovery.

## Timeline

| Time | Observation or action | Evidence link |
|---|---|---|
| `YYYY-MM-DD HH:MM TZ` | Event | Sanitized log, dashboard, test, or runbook reference. |

## Detection and response

Describe the signal that detected the issue, the investigation steps, the change or rollback, and the validation that confirmed recovery.

## Follow-up

- [ ] I updated a runbook, decision record, lesson, or evidence item where needed.
- [ ] I opened a scoped remediation issue or pull request.
- [ ] I checked whether a secret, private detail, or public artifact requires rotation, removal, or reclassification.
- [ ] I recorded the limitation or unanswered question that remains.

## Evidence classification

Public | Internal project | Confidential | Restricted

---
estimated_duration: 20m
---

# Lab: Enforcing Controls With Admission Policy

Graded lab for the admission policy module. The policy `require-memory-limits` starts with a wrong expression and a binding that only warns and selects no namespace, and the `probe` Deployment has no memory limit. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-041-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-binding-denies.sh` | A binding of `require-memory-limits` lists the `Deny` action |
| `validate-starfleet-rejects.sh` | A server-side dry run of a Deployment without a memory limit is rejected by the policy in `starfleet` (retries up to 20 seconds) |
| `validate-limits-not-requests.sh` | A Deployment with only `limits.memory` is accepted and one with only `requests.memory` is rejected |
| `validate-outpost-unaffected.sh` | A Deployment without a limit is still accepted in `outpost`, and `outpost` has no `control-scope` label |
| `validate-probe-complies.sh` | Every container of `probe` has a memory limit and `scout`, `probe` and `shuttle` are available |

`outpost-unaffected` passes before any change, because the binding selects no namespace. It fails if a change widens the scope too far.

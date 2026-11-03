---
estimated_duration: 30m
---

# Capstone: Controls And Frameworks

Capstone for the controls section. The new team namespace `orbit` must meet a fleet security standard: Pod Security labels, no privileged workload, a memory-limit policy bound to it, and a compliant `relay` Deployment. It uses both a preventive and a detective control and keeps the rest of the cluster unchanged. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-041-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-orbit-labels.sh` | `orbit` has `enforce=baseline`, `warn=restricted` and `audit=restricted` |
| `validate-orbit-privileged.sh` | A privileged pod is rejected in `orbit` by a server-side dry run, `beacon-debug` is gone and no privileged pod runs there |
| `validate-binding-scope.sh` | A Deployment without a memory limit is rejected by `require-memory-limits` in `orbit` and accepted in `starfleet` and `outpost` |
| `validate-relay-complies.sh` | `relay` has a memory limit, `automountServiceAccountToken: false` in the template, no mounted token and an available replica |
| `validate-nothing-else-changed.sh` | `starfleet` and `outpost` have no Pod Security labels, every binding of the policy selects only `orbit` by name, and `scout` runs |

`nothing-else-changed` passes before any change. It fails if a change reaches `starfleet` or `outpost`.

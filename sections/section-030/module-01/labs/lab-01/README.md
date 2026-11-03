---
estimated_duration: 20m
---

# Lab: Controls, Risk And Frameworks

Graded lab for the controls module. The `starfleet` namespace starts with no Pod Security labels, a privileged `debug-tools` Deployment and a `shuttle` that mounts a service account token. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-041-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-enforce-baseline.sh` | The label `pod-security.kubernetes.io/enforce` on `starfleet` is exactly `baseline` |
| `validate-warn-audit-restricted.sh` | The `warn` and `audit` labels on `starfleet` are both `restricted` |
| `validate-privileged-removed.sh` | A server-side dry run of a privileged pod fails with `violates PodSecurity`, the `debug-tools` Deployment is gone and no privileged pod runs in `starfleet` |
| `validate-shuttle-no-token.sh` | The `shuttle` pod template sets `automountServiceAccountToken: false` and no running `shuttle` pod mounts the token directory |
| `validate-workloads-run.sh` | `scout`, `probe` and `shuttle` are available, `shuttle` gets HTTP 200 from `scout`, and `outpost` has no Pod Security labels |

`workloads-run-and-outpost-untouched` passes before any change, because the workloads run. It fails if a change breaks them.

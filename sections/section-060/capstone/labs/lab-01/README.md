---
estimated_duration: 30m
---

# Capstone Lab: Securing The Beacon Workload

Graded capstone for the workload and application code security section. The `beacon` service in `orbit` has a literal token in its pod template, no container settings, no limits, no quota, and a service account that can read Secrets. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-041-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-token-from-secret.sh` | Secret `beacon-credentials` holds the original token, `API_TOKEN` uses `secretKeyRef`, no literal token in the template |
| `validate-beacon-hardened.sh` | Non-root user `65532`, `RuntimeDefault`, no privilege escalation, read-only root, `ALL` dropped, not privileged |
| `validate-beacon-bounded.sh` | Memory request and limit on the container; ResourceQuota `orbit-quota` with `pods` `5` and `limits.memory` `512Mi` |
| `validate-no-api-access.sh` | `can-i` answers no for get, list and watch on Secrets, token mount disabled, the service account still exists |
| `validate-beacon-serving.sh` | Rollout complete, live pods carry the settings, the Service has a ready endpoint |

All five checks fail until the task is done.

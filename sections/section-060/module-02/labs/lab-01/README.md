---
estimated_duration: 20m
---

# Lab: Containing A Compromised Workload

Graded lab for the containment module. The Starfleet workloads in `starfleet` start with no `securityContext`, and the namespace has no LimitRange and no ResourceQuota. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-041-lab-060-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-hardened.sh` | The `probe` template has `runAsNonRoot`, user `65532`, `RuntimeDefault`, no privilege escalation, a read-only root, `ALL` dropped, not privileged |
| `validate-probe-available.sh` | The `probe` rollout is complete, running pods carry the settings, the Service has an endpoint, `scout`, `shuttle` and `drifter` are unchanged |
| `validate-limitrange-defaults.sh` | LimitRange `container-defaults` has a `Container` limit with `defaultRequest` memory `32Mi` and `default` memory `64Mi` |
| `validate-quota-spec.sh` | ResourceQuota `starfleet-quota` has hard `pods` `10` and `limits.memory` `1Gi` |
| `validate-quota-enforced.sh` | Server-side dry runs: a pod with no resources is admitted, and a pod with a `2Gi` memory limit is rejected with `exceeded quota` |

All five checks fail until the task is done.

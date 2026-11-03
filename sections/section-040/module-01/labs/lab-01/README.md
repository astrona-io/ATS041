---
estimated_duration: 15m
---

# Lab: Remove Host Access From A Workload

Graded lab for the isolation module. The `relay` Deployment in `outpost` shares the node's PID, network and IPC namespaces, runs a privileged container, mounts a host directory and receives a service account token. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-041-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-host-namespaces-off.sh` | `hostPID`, `hostNetwork` and `hostIPC` are not `true` in the pod template |
| `validate-container-not-privileged.sh` | Not privileged, `allowPrivilegeEscalation: false`, drops `ALL`, adds no capability |
| `validate-no-host-path.sh` | No `hostPath` volume and no mount of `host-logs` |
| `validate-token-not-mounted.sh` | `automountServiceAccountToken` is `false` on the pod template (or unset there and `false` on the service account) |
| `validate-relay-running-hardened.sh` | Rollout finished, label, image and read-only root filesystem kept, live pods have no host access |

All five checks fail before any change.

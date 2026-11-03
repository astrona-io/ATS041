---
estimated_duration: 20m
---

# Lab: Application Code And Workload Protection

Graded lab for the credentials module. The `ledger` Deployment in `starfleet` starts with its database password written into the pod template, and the `shuttle` service account may read every Secret in the namespace. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-041-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-secret-holds-the-password.sh` | Secret `ledger-db` exists and its key `password` decodes to the original value |
| `validate-no-plaintext-credential.sh` | The original value and the `DB_PASSWORD` variable are gone from the whole `ledger` pod template |
| `validate-secret-mounted-read-only.sh` | A `secret` volume `db-credentials` for `ledger-db` is mounted read only at `/etc/ledger-db` in `ledger` |
| `validate-shuttle-cannot-read-secrets.sh` | `can-i` answers `no` for `get`, `list` and `watch` on Secrets for `shuttle`, and the service account exists |
| `validate-ledger-available.sh` | The `ledger` rollout is complete and `scout`, `probe`, `shuttle` and `drifter` are available with their original images |

`ledger-available` passes before any change. The other four fail until the task is done.

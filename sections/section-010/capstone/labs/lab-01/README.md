---
estimated_duration: 30m
---

# Capstone Lab: The 4Cs of Cloud Native Security

Graded capstone for the section. A new namespace `relay` has a privileged `beacon` Deployment that mounts a node directory, a service account bound to `cluster-admin`, a token that is mounted but not needed, an unmanaged privileged pod and no Pod Security labels. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-041-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-cluster-admin-removed.sh` | No `cluster-admin` binding for `beacon`; the service account exists; `can-i list secrets` answers `no` |
| `validate-beacon-token-not-mounted.sh` | `automountServiceAccountToken` is `false` and running pods have no `kube-api-access` volume |
| `validate-beacon-hardened.sh` | The template meets the restricted settings and has no `hostPath` volume |
| `validate-relay-enforces-restricted.sh` | The `enforce` label is `restricted`; a privileged dry-run pod is rejected and a compliant one is accepted |
| `validate-stray-removed-and-beacon-ready.sh` | `stray` is gone and `beacon` is rolled out and ready |

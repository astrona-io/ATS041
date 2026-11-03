---
estimated_duration: 20m
---

# Lab: Security Across Cloud, Cluster, Container And Code

Graded lab for the four-layers module. The cluster starts with a service account bound to `cluster-admin`, a pod that receives an API token it does not need, and a privileged container with a host path mount. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-041-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-cluster-admin-removed.sh` | No binding of `shuttle` to `cluster-admin` remains, the service account exists, and `can-i list secrets` answers `no` |
| `validate-shuttle-token-not-mounted.sh` | `automountServiceAccountToken` is `false` (pod or service account) and running pods have no `kube-api-access` volume |
| `validate-scout-hardened.sh` | Not privileged, `allowPrivilegeEscalation` false, `ALL` dropped, non-root user, no `hostPath` volume |
| `validate-scout-available.sh` | The hardened Deployment rolls out and has a ready replica |
| `validate-other-workloads-unchanged.sh` | `probe` and `drifter` unchanged and ready; no workload service account has `cluster-admin` |

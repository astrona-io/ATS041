---
estimated_duration: 20m
---

# Lab: Cloud And Infrastructure Responsibilities

Graded lab for the infrastructure identity module. The `starfleet` namespace starts with workloads that all receive a service account token, a `build-runner` service account bound to `cluster-admin`, and no policy against the cloud metadata address. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-041-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-tokens-not-mounted.sh` | `scout` and `probe` set `automountServiceAccountToken: false`, and no running pod of either has a service account token volume |
| `validate-metadata-egress-blocked.sh` | A NetworkPolicy selecting all pods in `starfleet` has an egress `ipBlock` of `0.0.0.0/0` that excludes the metadata address, and no policy allows egress to everything |
| `validate-build-runner-not-admin.sh` | `build-runner` cannot do everything, cannot delete nodes and cannot read Secrets in any namespace |
| `validate-build-runner-updates-deployments.sh` | `build-runner` can patch Deployments in `starfleet`, and cannot delete them or patch them in `outpost` |
| `validate-workloads-still-run.sh` | `scout`, `probe` and `shuttle` have every replica available, `drifter` exists and `outpost` has no NetworkPolicy |

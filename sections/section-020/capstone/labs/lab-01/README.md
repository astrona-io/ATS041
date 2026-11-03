---
estimated_duration: 30m
---

# Lab: Cloud Provider and Infrastructure Security Capstone

Capstone for the section. The `outpost` namespace starts with five findings: a token the workload never uses, a `cluster-admin` binding, no policy against the cloud metadata address, anonymous `view` access and a host path Deployment. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-041-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-drifter-token-removed.sh` | `drifter` sets `automountServiceAccountToken: false`, no running pod has a token volume and the Deployment is available |
| `validate-drifter-least-privilege.sh` | `drifter` cannot do everything, delete nodes or read Secrets, and can get and list ConfigMaps in `outpost` |
| `validate-metadata-egress-blocked.sh` | A NetworkPolicy selecting all pods in `outpost` has an egress `ipBlock` of `0.0.0.0/0` that excludes the metadata address, and no policy allows egress to everything |
| `validate-anonymous-access-removed.sh` | An unauthenticated caller cannot list pods or Secrets in `outpost`, and `system:public-info-viewer` still exists |
| `validate-outpost-node-boundary.sh` | `outpost` enforces exactly `baseline`, no workload mounts a host path, and a dry run rejects a host path pod and accepts a plain pod |

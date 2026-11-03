---
estimated_duration: 20m
---

# Lab: Control Plane, Node And Data Boundaries

Graded lab for the control plane, node and data module. The `starfleet` namespace starts with a binding that gives the `view` role to unauthenticated callers, a Deployment that mounts a host path, no Pod Security labels, and a service account that reads Secrets. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-041-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-anonymous-access-removed.sh` | An unauthenticated caller cannot list pods or read Secrets in `starfleet`, and the built-in `system:public-info-viewer` binding still exists |
| `validate-node-inspector-removed.sh` | `node-inspector` is gone and no pod or Deployment in `starfleet` has a host path volume |
| `validate-baseline-enforced.sh` | The label `pod-security.kubernetes.io/enforce` on `starfleet` is exactly `baseline`, and a server-side dry run of a host path pod fails with `violates PodSecurity` while a plain pod is accepted |
| `validate-scout-cannot-read-secrets.sh` | `scout` cannot get or list Secrets in `starfleet` and can get the ConfigMap `fleet-settings` |
| `validate-workloads-and-secret-intact.sh` | `scout`, `probe` and `shuttle` have every replica available, the Secret `drive-credentials` exists and `outpost` has no Pod Security enforce label |

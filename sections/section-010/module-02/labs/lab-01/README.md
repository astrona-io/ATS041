---
estimated_duration: 20m
---

# Lab: Defense In Depth: Preventive, Detective And Corrective Controls

Graded lab for the controls module. The cluster starts with a namespace without Pod Security labels, an unmanaged privileged pod, and a Deployment stuck on a missing image. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-041-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-outpost-enforces-baseline.sh` | The `enforce` label on `outpost` is `baseline` or `restricted` |
| `validate-privileged-pod-rejected.sh` | A server-side dry run of a privileged pod fails with a PodSecurity error; a plain pod passes |
| `validate-audit-and-warn-restricted.sh` | The `audit` and `warn` labels are `restricted` |
| `validate-intruder-removed.sh` | `intruder` is gone and `drifter` is ready |
| `validate-probe-rolled-back.sh` | `probe` uses `mccutchen/go-httpbin:2.25.0` and the rollout is complete |

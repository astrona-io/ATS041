---
estimated_duration: 20m
---

# Lab: Allow Only Approved Registries

Graded lab for admission policy on image registries. The cluster starts without any admission policy. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-041-lab-050-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-policy-and-binding-defined.sh` | Policy `approved-registries` matches pods, has `failurePolicy: Fail`, and a binding has `Deny` |
| `validate-approved-images-admitted-in-dockyard.sh` | Approved prefixes are admitted (server-side dry run) |
| `validate-unapproved-images-rejected-in-dockyard.sh` | `docker.io` and two look-alike prefixes are rejected |
| `validate-init-containers-checked.sh` | An unapproved init container is rejected |
| `validate-other-namespaces-unaffected.sh` | `outpost` admits any image and `stray` still exists |

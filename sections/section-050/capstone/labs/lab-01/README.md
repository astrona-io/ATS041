---
estimated_duration: 30m
---

# Lab: Artifact Supply Chain Capstone

Capstone for the section: digest pinning, pull credentials on a service account and an admission policy that requires digests. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-041-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cargo-pinned-to-recorded-digest.sh` | `cargo` uses the recorded digest, no tag, 0 replicas |
| `validate-pull-credentials-through-serviceaccount.sh` | Secret content, ServiceAccount reference, dry-run inheritance, no Deployment-level secret |
| `validate-digest-policy-defined.sh` | `require-image-digest` matches pods, `failurePolicy: Fail`, a scoped binding with `Deny` |
| `validate-digest-required-in-shipyard.sh` | Digest pods admitted; tag-only, tag-only init and malformed digests rejected |
| `validate-scope-limited-to-shipyard.sh` | Tag-only pods admitted in `outpost` and `kube-system` |

---
estimated_duration: 15m
---

# Lab: Pin Images By Digest And Attach Pull Credentials

Graded lab for image references and pull credentials. The cluster starts with a Deployment that uses a mutable tag, no pull secret and a service account without one. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-041-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-relay-pinned-by-digest.sh` | `relay` uses `repository@digest` equal to the release record, with no tag |
| `validate-relay-and-hauler-otherwise-unchanged.sh` | Both Deployments stay at 0 replicas and `hauler` keeps its image (passes before any change) |
| `validate-pull-secret-correct.sh` | `registry-creds` has type dockerconfigjson, the right server, user and password |
| `validate-hauler-serviceaccount-uses-pull-secret.sh` | The `hauler` ServiceAccount lists `registry-creds` |
| `validate-new-pods-inherit-pull-secret.sh` | A dry-run pod on `hauler` receives the secret and the Deployment sets none itself |

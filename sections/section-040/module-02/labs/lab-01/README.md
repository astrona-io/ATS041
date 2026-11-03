---
estimated_duration: 20m
---

# Lab: Segment A Namespace With Network And Resource Controls

Graded lab for the segmentation module. The namespace `depot` runs `ledger` and `loader` with no NetworkPolicy, no ResourceQuota, no LimitRange and token mounts on. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-041-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-default-deny-ingress.sh` | A policy with an empty `podSelector`, `Ingress` and no ingress rule exists (an Egress-only policy fails) |
| `validate-ledger-allow-rules.sh` | Policies for `app=ledger` allow only `loader` (same namespace) and one AND peer for `shuttle` in `starfleet`, only TCP 8080 |
| `validate-resource-quota.sh` | A quota with `pods` at most 10, `requests.cpu`, `requests.memory` and `limits.memory` |
| `validate-limit-range-defaults.sh` | A Container LimitRange with defaults and `max.memory`, and a server-side dry run of a pod without resources gets defaults |
| `validate-tokens-not-mounted.sh` | `ledger` and `loader` service accounts have `automountServiceAccountToken: false`, Deployments keep their images |

NetworkPolicy is graded by its spec, so the checks do not depend on the network plugin. All five checks fail before any change.

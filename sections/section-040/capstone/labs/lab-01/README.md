---
estimated_duration: 30m
---

# Capstone: Isolate A Namespace

Graded capstone for the isolation techniques section. The namespace `annex` runs `scribe` and `courier`. `courier` has host access and a token, and the namespace has no NetworkPolicy, ResourceQuota or LimitRange. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse, fixture tests of the jq logic with a fake kubectl). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-041-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-courier-host-access-removed.sh` | No host namespaces, not privileged, no privilege escalation, `drop: ALL` with no `add`, no `hostPath` volume, no token |
| `validate-scribe-ingress-segmented.sh` | Default deny ingress for every pod, and scribe accepts only courier (same namespace) on TCP 8080 |
| `validate-courier-egress-restricted.sh` | Every courier egress rule is scribe on 8080 or kube-system DNS on 53, with scribe and UDP DNS present |
| `validate-namespace-resource-caps.sh` | A quota with `pods` at most 6, `requests.memory`, `limits.memory`, and a Container LimitRange with memory defaults |
| `validate-workloads-running.sh` | Both Deployments are rolled out with their labels and images, and live courier pods have no host access |

All five checks fail before any change.

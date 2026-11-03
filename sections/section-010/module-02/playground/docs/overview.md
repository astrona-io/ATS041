# Overview: Defense In Depth (Playground)

This is a playground, not a lab. It starts a cluster with the example workloads and one unmanaged privileged pod, and then waits. There is no task, no `astrona submit` and no pass or fail. Add controls, test them, break them, run `astrona destroy`, and start again.

## What is in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `outpost` | pod `intruder` | A privileged pod that no Deployment manages |

- Neither namespace has Pod Security labels, so both admit any pod.

## Helper

Paste this once in each terminal. It asks the API server to validate a privileged pod in a namespace without creating it (a server-side dry run), so you can see whether an admission control rejects it.

```sh
try_privileged_pod() {
  kubectl run "probe-test" -n "$1" --image=curlimages/curl:8.22.0 --dry-run=server \
    --overrides='{"spec":{"containers":[{"name":"probe-test","image":"curlimages/curl:8.22.0","securityContext":{"privileged":true}}]}}' -- sleep 30
}
```

Use it like this: `try_privileged_pod outpost`. Before you add any label, the command succeeds.

## Ideas to try

- Label `outpost` with `pod-security.kubernetes.io/enforce=baseline` and run `try_privileged_pod outpost` again. Then check whether `intruder` is still running, and explain why.
- Add `pod-security.kubernetes.io/warn=restricted` to `outpost` and run `kubectl apply` on a plain pod to read the warning.
- Delete the Deployment pod `scout` and watch the ReplicaSet create a new one. Then delete `intruder` and see that nothing replaces it.
- Run `kubectl set image deployment/probe probe=mccutchen/go-httpbin:does-not-exist -n starfleet`, watch the rollout stall, and recover with `kubectl rollout undo deployment/probe -n starfleet`.
- Run `kubectl get events -n starfleet --sort-by=.lastTimestamp` after each experiment and read what the cluster recorded.

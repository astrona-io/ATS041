# Overview: Containing A Compromised Workload (Playground)

This is a playground, not a lab. It starts a fresh cluster with two agents that differ only in their container settings, and then waits. There is no task, no `astrona submit` and no pass or fail. Change settings, break them, run `astrona destroy`, and start over.

## What is in the box

A single-node `kind` cluster running Kubernetes 1.35. The `kubectl` command points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle`. `loose-agent` runs as root with no `securityContext`. `tight-agent` runs as user 100 with `runAsNonRoot`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem`, all capabilities dropped and the `RuntimeDefault` seccomp profile. No LimitRange and no ResourceQuota |
| `outpost` | `drifter`, a curl client |

## Helpers

Paste these once in each new terminal. `proc_status` prints the capability, privilege and seccomp lines of a Deployment's process. `qos` lists the quality of service class of every pod in `starfleet`.

```sh
proc_status() {
  kubectl -n starfleet exec "deploy/$1" -- grep -E 'CapEff|NoNewPrivs|Seccomp:' /proc/self/status
}
qos() {
  kubectl -n starfleet get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
}
```

Use them like this: `proc_status loose-agent`, `proc_status tight-agent`, `qos`.

## Practice tasks

- Compare `proc_status` for both agents. Predict each value before you run it.
- Remove one setting at a time from `tight-agent` (for example `allowPrivilegeEscalation`) and see which line of `proc_status` changes.
- Set `runAsNonRoot: true` on a Deployment and remove `runAsUser`. Read the pod status and explain the error for an image with a named user.
- Give `probe` a memory limit of `8Mi` and watch the pod status. Find the reason and the exit code of the last state.
- Create a LimitRange and then a pod with no `resources`. Read the stored resources.
- Create a ResourceQuota with `pods` equal to the number of running pods and run `kubectl -n starfleet rollout restart deployment/scout`. Read the ReplicaSet events.

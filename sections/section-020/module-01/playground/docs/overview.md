# Overview: Cloud And Infrastructure Responsibilities (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and one over-privileged identity, and then waits. There is no task, no `astrona submit` and no pass or fail. Change objects, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator. The cluster is self-managed: the control plane runs as pods in `kube-system`.

  | Namespace | What is in it |
  | --- | --- |
  | `starfleet` | `scout`, `probe` and `shuttle`, each with its own service account, and all with the default token mount. A `build-runner` service account is bound to `cluster-admin` by the ClusterRoleBinding `build-runner-admin` |
  | `outpost` | The `drifter` client |

## Helpers

Paste these once in each new terminal. `can_runner` asks what the `build-runner` service account may do. `mounted_files` lists the credential files a workload can read.

```sh
can_runner() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:build-runner
}
mounted_files() {
  kubectl -n "$1" exec "deploy/$2" -- ls /var/run/secrets/kubernetes.io/serviceaccount
}
```

Use them like this: `can_runner delete nodes`, `can_runner get secrets --all-namespaces`, `mounted_files starfleet shuttle`.

## Practice tasks

- List the pods in `kube-system` and write down which component is the API server, which holds the data and which decides where pods run. Say who would run each one in a managed service.
- Read the flags of the API server pod with `jq` and find `--authorization-mode`.
- Turn off the token mount for `probe` with `automountServiceAccountToken: false`, wait for the rollout, and compare `mounted_files` before and after.
- Replace the `build-runner-admin` binding with a Role that allows `get`, `list` and `patch` on Deployments in `starfleet` only. Check three actions with `can_runner`.
- Write a NetworkPolicy for `outpost` that allows all egress except `169.254.169.254/32`, and read it back with `kubectl get networkpolicy -o yaml`. Decide whether it stops a request on this cluster, and what you would check to find out.

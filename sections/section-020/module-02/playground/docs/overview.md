# Overview: Control Plane, Node And Data Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with four exposure paths in place, and then waits. There is no task, no `astrona submit` and no pass or fail. Change objects, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

  | Namespace | What is in it |
  | --- | --- |
  | `starfleet` | `scout`, `probe` and `shuttle`. The ClusterRoleBinding `public-view` gives the `view` ClusterRole to the group `system:unauthenticated`. The Deployment `node-inspector` mounts the node's `/etc/kubernetes` at `/node-etc` and runs as root. The Secret `drive-credentials`, the ConfigMap `fleet-settings`, and a Role and RoleBinding `scout-secrets` that let `scout` read Secrets |
  | `outpost` | The `drifter` client |

## Helpers

Paste these once in each new terminal. `as_anonymous` asks the API server a question as an unauthenticated caller. `psa_test` runs a server-side dry run of an `enforce` level on a namespace.

```sh
as_anonymous() {
  kubectl auth can-i "$@" --as=system:anonymous --as-group=system:unauthenticated
}
psa_test() {
  kubectl label --dry-run=server --overwrite namespace "$1" "pod-security.kubernetes.io/enforce=$2"
}
```

Use them like this: `as_anonymous list pods -n starfleet`, `as_anonymous get /version`, `psa_test starfleet baseline`.

## Practice tasks

- Before you change anything, predict the answers of `as_anonymous list pods -n starfleet`, `as_anonymous get secrets -n starfleet` and `as_anonymous get /version`. Then run them.
- Find every ClusterRoleBinding that names `system:unauthenticated` with `kubectl get clusterrolebindings -o json | jq`. Decide which one to keep.
- Predict what `psa_test starfleet baseline` says about `node-inspector`, then run it. Try `psa_test starfleet restricted` and compare the list.
- Use `node-inspector` to list `/node-etc/manifests`, then decide what a user could learn or change with a writable mount of `/`.
- Count the `encryption-provider-config` flags on the API server pod. Write the `EncryptionConfiguration` you would use for Secrets with a KMS provider, and say which party owns the key.
- Replace the `scout-secrets` grant with a Role limited to the ConfigMap `fleet-settings`, and check three actions with `kubectl auth can-i --as`.

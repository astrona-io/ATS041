# Overview: Enforcing Controls With Admission Policy (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Write policies, bind them, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. ValidatingAdmissionPolicy is built in and generally available; there is no policy engine to install. `jq` runs on your machine.

  | Namespace | What is in it |
  | --- | --- |
  | `starfleet` | `scout` and `shuttle` set a memory limit. `probe` does not, on purpose |
  | `outpost` | The `drifter` client runs here |

## Helpers

Paste these once in each new terminal. `try_nolimits` sends a Deployment without a memory limit through admission as a server-side dry run in the namespace you give. `list_bindings` prints each binding with its policy and actions. `deployments_without_limits` lists Deployments in which a container has no memory limit.

```sh
try_nolimits() {
  kubectl -n "$1" create deployment trial-nolimits --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
}
list_bindings() {
  kubectl get validatingadmissionpolicybindings -o json | jq -r '.items[] | "\(.metadata.name) policy=\(.spec.policyName) actions=\(.spec.validationActions | join(","))"'
}
deployments_without_limits() {
  kubectl get deployments -A -o json | jq -r '.items[] | select(any(.spec.template.spec.containers[]; (.resources.limits.memory // null) == null)) | "\(.metadata.namespace)/\(.metadata.name)"'
}
```

Use them like this: `try_nolimits starfleet`, `list_bindings`, `deployments_without_limits`.

## Practice tasks

- Create a ValidatingAdmissionPolicy that requires `resources.limits.memory` on every container of a Deployment. Predict what `try_nolimits starfleet` prints before you create a binding, then create the binding and run it again.
- Start the binding with `validationActions: ["Warn"]`, then patch it to `["Deny", "Audit"]`. Try to set `["Deny", "Warn"]` and read the error.
- Make the binding match only namespaces with a label of your choice. Label `starfleet`, and check that `outpost` is not affected.
- Change `probe` so that it passes the policy. Find out what the API server says if you update `probe` before you add the limit.
- Look for a gap: send a bare pod and a StatefulSet without a limit and see whether the policy sees them.

# Overview: Controls, Risk And Frameworks (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and one privileged Deployment, and then waits. There is no task, no `astrona submit` and no pass or fail. Change labels, collect evidence, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. Pod Security Admission is built in; there is no policy engine. `jq` runs on your machine.

  | Namespace | What is in it |
  | --- | --- |
  | `starfleet` | No Pod Security labels. `scout`, `probe` and `shuttle` run with no `securityContext`. `debug-tools` runs a privileged container, on purpose |
  | `outpost` | No Pod Security labels. The `drifter` client runs here |

## Helpers

Paste these once in each new terminal. `psa_labels` prints the Pod Security labels of a namespace. `psa_dry_run` tests a label against the running pods without changing anything. `privileged_pods` lists every pod with a privileged container.

```sh
psa_labels() {
  kubectl get namespace "$1" -o json | jq '.metadata.labels | with_entries(select(.key | startswith("pod-security")))'
}
psa_dry_run() {
  kubectl label --dry-run=server --overwrite namespace "$1" "pod-security.kubernetes.io/$2=$3"
}
privileged_pods() {
  kubectl get pods -A -o json | jq -r '.items[] | select(any(.spec.containers[]; .securityContext.privileged == true)) | "\(.metadata.namespace)/\(.metadata.name)"'
}
```

Use them like this: `psa_labels starfleet`, `psa_dry_run starfleet warn baseline`, `privileged_pods`.

## Practice tasks

- Before you change anything, predict which pods `psa_dry_run starfleet enforce baseline` reports. Then run it.
- Label `starfleet` with `warn` and `audit` at `baseline`, then create a privileged pod with `kubectl apply --dry-run=server`. Find out whether it is admitted and where the warning appears.
- Change the mode of the same level to `enforce`. Check that the `debug-tools` pod keeps running, and find out what happens when you delete that pod.
- Write the evidence queries for your own checklist: namespaces without an `enforce` label, `cluster-admin` bindings, pods that mount a service account token.
- Create a namespace `ops` that allows `privileged` but warns and audits at `baseline`. Compare how the same pod behaves there and in `starfleet`.

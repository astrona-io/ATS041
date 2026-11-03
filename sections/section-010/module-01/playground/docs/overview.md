# Overview: Security Across Cloud, Cluster, Container And Code (Playground)

This is a playground, not a lab. It starts a cluster with the example workloads and two deliberate weaknesses, and then waits. There is no task, no `astrona submit` and no pass or fail. Look at each layer, break things, run `astrona destroy`, and start again.

## What is in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator. The cluster node is a container that stands in for a cloud virtual machine.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `starfleet` | `legacy-agent` | A pod whose service account is bound to `cluster-admin` by the ClusterRoleBinding `legacy-agent-admin` |
  | `starfleet` | `privileged-debug` | A privileged pod that mounts the node directory `/etc` read-only at `/host-etc` |

## Helper

Paste this once in each terminal. It takes a namespace and a Deployment name, and asks the API server to list Secrets as the service account of that pod, using the token mounted in that pod, and prints the HTTP status code.

```sh
api_status() {
  kubectl exec -n "$1" "deploy/$2" -- sh -c 'curl -s -o /dev/null -w "%{http_code}\n" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/'"$1"'/secrets'
}
```

Use it like this: `api_status outpost drifter` and `api_status starfleet legacy-agent`.

## Ideas to try

- Run `api_status` for `drifter` and for `legacy-agent` and explain the two status codes from the bindings in the cluster.
- Read the securityContext of `scout` and of `privileged-debug` with `kubectl get ... -o jsonpath` and list every field that differs.
- Run `kubectl exec -n starfleet deploy/privileged-debug -- ls /host-etc` and compare it with `kubectl exec -n starfleet deploy/scout -- ls /etc`.
- Set `automountServiceAccountToken: false` in the pod template of `shuttle` with `kubectl patch` and check that the token file no longer exists in the new pod.
- Delete the ClusterRoleBinding `legacy-agent-admin` and run `api_status starfleet legacy-agent` again.

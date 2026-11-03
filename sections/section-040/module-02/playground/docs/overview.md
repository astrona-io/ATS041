# Overview: Network And Resource Segmentation (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Write policies and quotas, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads and two extra objects:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application. `probe` listens on container port 8080 behind a Service on port 80 |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `trial` | (empty namespace) | A place for LimitRange and ResourceQuota experiments |
  | cluster-wide | RuntimeClass `sandboxed` | Handler `runsc`; the node has no such handler, so only read it |

- No NetworkPolicy, ResourceQuota or LimitRange exists. Whether a NetworkPolicy is enforced depends on the network plugin of the kind cluster. Test both outcomes.

## Helpers

Paste this once in each new terminal. `status_of` prints the HTTP status code that a client pod gets from a URL, or `000` when the request times out:

```sh
status_of() {
  kubectl exec "deploy/$1" -n "$2" -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' "$3"
}
```

Use it like this: `status_of shuttle starfleet http://probe/status/200` and `status_of drifter outpost http://probe.starfleet.svc.cluster.local/status/200`.

## Practice tasks

- Apply a default deny ingress policy to `starfleet`, then add a policy that lets only `shuttle` reach `probe` on port 8080. Predict the result for `drifter` before you run it.
- Change the allow policy so that it allows every pod of the namespace `outpost`. Write the version with a `namespaceSelector` on `kubernetes.io/metadata.name`.
- Write one policy that has an OR between two peers and one with an AND, and say which pods each one allows.
- Add an egress policy for `shuttle` that allows only `probe` on port 8080, then add the DNS rule that name resolution needs.
- In `trial`, set a LimitRange with a memory default and a quota on `pods`, then create pods until the quota rejects one. Read the error message.
- Label and taint the node, start a pod without a toleration and read why it is `Pending`. Remove the taint when you are done.

## Tips

- A policy port is the container port: 8080 for `probe`, not 80.
- `kubectl describe pod <name>` lists scheduling events at the bottom.
- A quota error names the quota, the requested amount, the used amount and the limit.

<!-- astrona:playground:destroy -->

# Overview: Application Code And Workload Protection (Playground)

This is a playground, not a lab. It starts a fresh cluster with the example workloads and a few credential problems, and then waits. There is no task, no `astrona submit` and no pass or fail. Change objects, break them, run `astrona destroy`, and start over.

## What is in the box

A single-node `kind` cluster running Kubernetes 1.35. The `kubectl` command points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (podinfo), `probe` (go-httpbin, echoes requests), `shuttle` (curl client). A Secret `scout-db` with the key `password`. A Deployment `legacy-report` with a literal `DB_PASSWORD` in its pod template. A Role `secret-reader` bound to the `shuttle` service account |
| `outpost` | `drifter`, a curl client |

## Helpers

Paste these once in each new terminal. `call_probe` sends a query value from `shuttle` to `probe`. `read_secret` prints and decodes one key of a Secret in `starfleet`. `who_can_read_secrets` asks the API server whether a service account may read Secrets.

```sh
call_probe() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s -G --data-urlencode "report=$1" http://probe.starfleet.svc.cluster.local/anything
}
read_secret() {
  kubectl -n starfleet get secret "$1" -o jsonpath="{.data.$2}" | base64 -d; echo
}
who_can_read_secrets() {
  kubectl auth can-i get secrets -n starfleet --as="system:serviceaccount:starfleet:$1"
}
```

Use them like this: `call_probe "1 OR 1=1"`, `read_secret scout-db password`, `who_can_read_secrets shuttle`.

## Practice tasks

- Send `probe` values with quotes, dots and slashes. Find the field of the response that holds your value, and note that nothing changed it.
- Call `probe` from `drifter` in `outpost`. Decide which component should refuse that caller if `probe` held private data.
- Find every place where the `legacy-report` password is visible: the Deployment, its ReplicaSet and its pod.
- Create a pod that reads `scout-db` through an environment variable and through a volume. Change the Secret and compare what each one shows over a few minutes.
- Remove the `shuttle-secret-reader` RoleBinding and run `who_can_read_secrets shuttle` again. Then write a Role that allows `get` on only `scout-db` with `resourceNames`.
- List the images in the cluster, and find which containers have no digest in their reference.

# Overview: Isolation And Containment Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and two extra workloads that share more than a normal pod does, and then waits. There is no task, no `astrona submit` and no pass or fail. Look at the isolation, break it, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads and two extra ones:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application. `shuttle` is a client with a shell and `curl` |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `starfleet` | `crew-share` | One pod with two containers, `main` and `side`, and `shareProcessNamespace: true` |
  | `outpost` | `relay` | A client pod with `hostPID: true`, so its containers see the processes of the node |

- No NetworkPolicy, no ResourceQuota and no Pod Security label exists in either namespace.

## Practice tasks

- Run `ps` inside `shuttle` and count the processes. Then run `ps` inside the `main` container of `crew-share` and name the process that the `side` container started.
- Compare the host name that `shuttle` reports with the name of its pod. Say which Linux namespace explains the match.
- From `drifter` in `outpost`, call the `probe` Service in `starfleet` by its full DNS name. Say why a Kubernetes namespace does not stop this request.
- Run `ps` inside `relay` and compare the list with the one from `shuttle`. Name the pod field that makes the difference.
- List the files in `/var/run/secrets/kubernetes.io/serviceaccount` in `shuttle`. Find the setting that stops a pod from receiving that token.
- Read the pod JSON of `relay` with `kubectl get pod -n outpost -l app=relay -o json | jq '.items[0].spec'` and list every field that widens what the pod can reach on the node.

## Tips

- `kubectl exec deploy/shuttle -n starfleet -- <command>` runs a command in the first container of the pod.
- Use `-c side` with `kubectl exec` to pick a container in a pod that has more than one.
- A pod field that is missing in the JSON has its default value. `hostPID` defaults to `false`.

<!-- astrona:playground:destroy -->

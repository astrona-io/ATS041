# Overview: Image References And Pull Credentials (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and a `dockyard` namespace, and then waits. There is no task, no `astrona submit` and no pass or fail. Try things, break them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `dockyard` | Deployment `relay` | Uses `ghcr.io/stefanprodan/podinfo:latest`, scaled to zero replicas |
  | `dockyard` | Deployment `hauler`, service account `hauler` | Uses `registry.starfleet.example/fleet/hauler:2.4`, scaled to zero replicas, no pull secret |
  | `dockyard` | Deployment `stray` | Uses `docker.io/library/busybox:1.37`, scaled to zero replicas |
  | `dockyard` | ConfigMap `release-record` | A recorded digest in the key `relay-digest` |

- No `Secret`, no `ValidatingAdmissionPolicy` and no `ValidatingAdmissionPolicyBinding` exists yet.
- The `dockyard` Deployments have zero replicas on purpose: no image is pulled, and the registry `registry.starfleet.example` does not exist.

## Practice tasks

- Run `kubectl -n starfleet get pods -o jsonpath='{range .items[*]}{.metadata.name}{"  "}{.status.containerStatuses[0].image}{"  "}{.status.containerStatuses[0].imageID}{"\n"}{end}'` and compare the `image` field with the `imageID` field for each pod.
- Read the pull policy that Kubernetes set on `relay` and on `scout` with `kubectl get deployment ... -o jsonpath='{.spec.template.spec.containers[0].imagePullPolicy}'`. Explain the difference.
- Create a `kubernetes.io/dockerconfigjson` Secret in `dockyard` with `kubectl create secret docker-registry`. Decode `.data.\.dockerconfigjson` with `base64 -d` and see that the password is readable.
- Give the secret to the service account `hauler` and use a server-side dry run to see that a new pod receives it.
- Set the image of `relay` to the repository and the digest from `release-record`. Then scale it up and read the pull failure with `kubectl describe pod`.

# Overview: Controlling Which Images Run (Playground)

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

- List every image of every pod and Deployment in the cluster with `kubectl get deployments -A -o jsonpath` or with `jq`, and find the ones that do not come from an approved registry.
- Write a `ValidatingAdmissionPolicy` that allows only `registry.starfleet.example/` and `ghcr.io/stefanprodan/` as image prefixes, and bind it to `dockyard` with the action `Warn` first. Create a pod and read the warning.
- Change the binding action to `Deny` and read the denied-request error.
- Add the action `Audit` next to `Deny` and find out where the audit annotation is recorded (API server audit logs are not enabled in this cluster).
- Write a second policy that requires digests, and test pods with a tag only, a digest only and a tag together with a digest.

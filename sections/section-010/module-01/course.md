---
draft: true
exam_objectives:
  - The 4Cs of Cloud Native Security
---
# Security Across Cloud, Cluster, Container And Code

A cloud native application runs on four layers, and each layer trusts the one below it. The cloud (or infrastructure) layer provides machines and networks. The cluster layer runs Kubernetes on those machines. The container layer runs the application's processes. The code layer is the application itself. The Kubernetes and Cloud Native Security Associate (KCSA) exam calls this the 4Cs of cloud native security: Cloud, Cluster, Container and Code.

Keep one sentence in mind for this module: **a control at one layer can only protect what that layer governs, and a weakness at an outer layer can undo a control at an inner layer.** You will see where each layer's authority ends, run a request as a pod that holds an over-powerful token, and fix weaknesses in three layers.

The module has three parts. The first names the asset, the responsibility and the trust relationship at each layer. The second looks at the cluster and container layers in a running cluster: the service account token, the container `securityContext` and a host directory mount. The third follows a compromised piece of code down through the layers and shows which control stops it at each step.

## Learning objectives

After this module you can:

- Identify the asset and the responsibility at each of the four security layers.
- Explain how a failure in an outer layer can undermine the controls of an inner layer.
- Read a pod specification and name which fields belong to the cluster layer and which to the container layer.
- Show with `kubectl` how much a service account token allows, and remove the excess.
- Explain what the platform can and cannot control when the application code is vulnerable.

## Before you start

You need Kubernetes basics: namespaces, Deployments, pods, and the commands `kubectl get`, `kubectl apply` and `kubectl exec`. You do not need any security tool.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. The cluster node is a container on your machine that stands in for a virtual machine in a cloud. The playground has these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application, each on a service account of the same name |
| `outpost` | `drifter` | A client that belongs to another team |
| `starfleet` | `legacy-agent` | A pod on a service account bound to `cluster-admin`, on purpose |
| `starfleet` | `privileged-debug` | A privileged pod that mounts the node directory `/etc`, on purpose |

You run every command as the cluster administrator, and you check other identities with `--as`. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->

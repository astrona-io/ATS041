---
exam_objectives:
  - Cloud Provider and Infrastructure Security
---
# Control Plane, Node And Data Boundaries

Three places hold the real power in a cluster: the API server that accepts every request, the nodes that run the containers, and the storage that keeps the cluster's data. A protection that guards one of them does not guard the others. This module explains how each boundary works, what its controls do and do not prove, and how an attacker moves from one boundary to the next when a control is missing.

The module has three parts. The first part separates network reachability of the API endpoint from authentication and authorization, and examines anonymous access. The second part shows why access to a node is access to everything on it, using a pod that mounts a host path, and how Pod Security Admission stops it. The third part covers data at rest: etcd encryption, secrets, disk encryption, keys and backups.

## Learning objectives

After this module you can:

- Explain that network reachability, authentication and authorization are separate controls for the API endpoint.
- Describe anonymous access to the API server and find a binding that grants it.
- Explain why a host path mount gives a pod access to the node and which Pod Security Standards level forbids it.
- Describe how etcd encryption at rest works, which providers exist and what it does not protect.
- Name the protections and the exposure paths of backups, disk encryption keys and secrets.

## Before you start

You need Kubernetes basics: namespaces, pods, Deployments, service accounts, RBAC bindings and the commands `kubectl get`, `kubectl apply`, `kubectl label` and `kubectl exec`. No cloud account or extra tool is needed. The playground is a single-node `kind` cluster, which stands in for a self-managed cluster.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The example workloads `scout`, `probe` and `shuttle`. A `node-inspector` Deployment mounts a directory of the node. A Secret called `drive-credentials` exists, and the `scout` service account may read secrets. A binding gives the `view` role to unauthenticated callers. All of this is there on purpose |
| `outpost` | The `drifter` client |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->

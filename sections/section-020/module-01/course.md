---
draft: true
exam_objectives:
  - Cloud Provider and Infrastructure Security
---
# Cloud And Infrastructure Responsibilities

A Kubernetes cluster runs on infrastructure: machines, networks, disks and an identity system that decides who may create or change them. Whoever controls that infrastructure controls the cluster on top of it, whatever the cluster's own settings say. This module explains who is responsible for which layer when a provider runs part of the platform, and how the identities and addresses of the infrastructure reach into the cluster.

The module has three parts. The first part sorts the duties of a cloud provider and a customer for self-managed and managed clusters. The second part follows infrastructure identities and service account tokens, and measures how much damage one stolen credential can do. The third part covers the instance metadata service, which hands credentials to workloads, and shows how a network policy keeps workloads away from it.

## Learning objectives

After this module you can:

- Explain shared responsibility for managed and self-managed infrastructure and name who owns a given control.
- Identify powerful infrastructure identities and describe the blast radius of each.
- Describe how a workload obtains an identity and when it should not receive one.
- Explain how the instance metadata service exposes credentials and how to restrict access to it.
- Compare network exposure controls with identity and permission controls.

## Before you start

You need Kubernetes basics: pods, Deployments, namespaces, service accounts and the commands `kubectl get`, `kubectl apply`, `kubectl patch` and `kubectl exec`. No cloud account is needed. The playground runs a single-node `kind` cluster (Kubernetes running inside a container) on your machine, so it stands in for a self-managed cluster that you operate yourself.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The example workloads `scout`, `probe` and `shuttle`, each with its own service account. A `build-runner` service account is bound to `cluster-admin` on purpose |
| `outpost` | The `drifter` client |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->

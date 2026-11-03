---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Isolation And Containment Boundaries

A container looks like a small machine, and a Kubernetes namespace looks like a wall around a team. Neither picture is accurate, and the exam tests exactly the gap between the picture and the mechanism. If you trust a boundary that does not exist, a single compromised pod can reach the node, the neighbours and the Kubernetes API. This module explains what the Linux kernel really isolates, what a Kubernetes namespace really scopes, and which pod fields connect a container to its node.

## Goals

- Explain what Linux namespaces, control groups, capabilities and system-call filters do, and which kernel every container on a node shares.
- Compare the isolation of a container with a virtual machine and with a sandboxed runtime.
- Explain why a Kubernetes namespace is a scope and not a security boundary.
- Name the pod fields that give a container access to the node, and the settings that remove that access.

## Learning objectives

After this module you can:

- Name the Linux namespace types and say what each one separates.
- Explain how a control group limits resource use and why it does not limit visibility.
- Show with a command that two pods in different Kubernetes namespaces can still reach each other.
- Explain what a mounted service account token gives an attacker and how to stop the mount.
- Read a pod spec and list every field that widens access to the node: `hostPID`, `hostNetwork`, `hostIPC`, `privileged`, `hostPath` and added capabilities.
- Write a `securityContext` that drops capabilities, blocks privilege escalation and uses a read-only root file system.

## Before you start

You need Kubernetes basics: pods, Deployments, Services, namespaces and the commands `kubectl get`, `kubectl apply` and `kubectl exec`. You also need `jq` on your machine for reading pod specs.

The playground is a single-node `kind` cluster running Kubernetes 1.35, with no extra tools. It holds these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application. `shuttle` is a client with a shell and `curl` |
| `outpost` | `drifter` | A client that belongs to another team |
| `starfleet` | `crew-share` | A pod with two containers that share one process namespace |
| `outpost` | `relay` | A client pod that runs with `hostPID: true` |

No `NetworkPolicy`, `ResourceQuota` or Pod Security label exists. You run every command as the cluster administrator.

## Order of the parts

The module has three parts and a summary. The first part follows one container down to the kernel and shows what is separated and what is shared. The second part looks at the Kubernetes namespace and the service account, and shows what they leave open. The third part reads a pod spec for host access and shows the settings that tighten a container.

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->

---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Network And Resource Segmentation

A cluster that runs several teams or several customers needs segments: parts that cannot freely reach or starve each other. Kubernetes does not draw those segments by itself. The default network is flat, resources are shared and every pod receives a credential. This module shows the controls that create segments, what each control protects, and the boundaries that only a separate runtime, node or cluster can provide.

## Goals

- Write NetworkPolicy objects that deny by default and allow specific paths, and explain when they have no effect.
- Cap the resource use of a namespace with a ResourceQuota and fill in missing values with a LimitRange.
- Reduce the identity a pod holds with service accounts and token settings.
- Compare sandboxed runtimes, dedicated nodes and separate clusters, and state what each one still shares.

## Learning objectives

After this module you can:

- Write a default deny ingress policy and an allow rule that names a pod label and a container port.
- Tell apart a `from` list with two peers (OR) and a peer with both a namespace selector and a pod selector (AND).
- Explain why a NetworkPolicy has no effect when the network plugin does not enforce it, and why an egress policy needs a DNS rule.
- Explain how `ResourceQuota` and `LimitRange` work together and read an `exceeded quota` error.
- Explain `RuntimeClass`, taints, tolerations and node selectors, and the limit of a toleration.
- Name what a separate node group or cluster still shares with the rest of the platform.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, labels and `kubectl apply`. The playground is a single-node `kind` cluster running Kubernetes 1.35. It holds these objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application. `probe` listens on container port 8080 behind a Service on port 80 |
| `outpost` | `drifter` | A client that belongs to another team |
| `trial` | (empty namespace) | A place for quota and LimitRange experiments |
| cluster-wide | RuntimeClass `sandboxed` | Handler `runsc`; the node has no such handler |

No NetworkPolicy, ResourceQuota or LimitRange exists. You run every command as the cluster administrator.

## Order of the parts

The module has three parts and a summary. The first part writes NetworkPolicy objects and explains selectors, ports and enforcement. The second part sets quotas, defaults and identity limits. The third part covers runtimes and nodes that avoid a shared kernel, and shows a taint and a toleration at work.

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->

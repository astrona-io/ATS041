---
draft: true
exam_objectives:
  - The 4Cs of Cloud Native Security
---
# Summary

The four Cs are Cloud, Cluster, Container and Code. Each layer has its own assets, owner and controls, and each layer trusts the one below it. The cloud layer provides machines, networks and the identities that manage them, under a shared responsibility between provider and customer. The cluster layer authenticates, authorizes and admits requests. The container layer isolates a process on a shared kernel. The code layer holds the business rules that no platform control can read.

Because of this trust, a failure in an outer layer weakens the controls inside it. A pod specification shows both the cluster and the container layer: the service account and token settings belong to the cluster, and the `securityContext` and host mounts belong to the container. A token is mounted by default, and a privileged pod or a host path mount is accepted when no admission control refuses it.

A flaw in the code lets an attacker run commands in a container. From there the service account token links the code to the cluster, and the RBAC binding decides whether it returns a `403` or full access. The platform cannot fix the flaw. It limits the damage with independent controls: a narrow role, no token where none is needed, and a restricted `securityContext`.

Key facts:

- Confidentiality, integrity and availability are the three goals of protecting an asset.
- `automountServiceAccountToken: false` in the pod specification stops the API server from adding the token volume; the pod value wins over the service account value.
- `privileged: true` and `hostPath` volumes are separate settings and need separate controls.
- Name the asset, the access path, the layer that enforces the rule and what happens if that layer fails.

<!-- astrona:playground:destroy -->

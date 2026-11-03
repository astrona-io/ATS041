---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Summary

A container is a normal Linux process that the container runtime starts with restricted views and limited resources. Linux namespaces restrict what the process sees: processes, network, mounts, host name, shared memory and user identifiers. A control group limits how much CPU and memory the process uses. Capabilities split the powers of root, and a seccomp profile filters system calls. These controls shrink what a process can do, but all containers on a node still call the same kernel. A virtual machine or a sandboxed runtime adds a separate kernel layer and is a stronger boundary at a higher cost.

A Kubernetes namespace is a scope for object names, rights, quotas and policies. It does not separate the network, the kernel or the node. Without a `NetworkPolicy`, pods in different namespaces reach each other. Segmentation needs a control for each layer: RBAC for the API, `NetworkPolicy` for packets, quotas for resources, service accounts for identity, and dedicated nodes, sandboxed runtimes or separate clusters for the kernel.

A service account token is mounted into every pod by default. A compromised pod gives its token, and therefore the rights of its service account, to the attacker. A workload that does not call the API should have `automountServiceAccountToken: false`.

The pod spec can switch isolation off. `hostPID`, `hostNetwork`, `hostIPC`, `privileged`, `hostPath` volumes and added capabilities connect a container to the node. The fields `allowPrivilegeEscalation: false`, `capabilities.drop: ["ALL"]`, `readOnlyRootFilesystem: true`, `runAsNonRoot: true` and `seccompProfile.type: RuntimeDefault` tighten a container. An admission control such as Pod Security Admission decides which pod specs enter the cluster. The key facts to remember are these:

- Containers on one node share one kernel; virtual machines do not.
- A Linux namespace changes what a process sees; a cgroup limits what it uses.
- A Kubernetes namespace is a scope, not a network or kernel boundary.
- Removing only the `volumeMount` does not remove a `hostPath` volume.

<!-- astrona:playground:destroy -->

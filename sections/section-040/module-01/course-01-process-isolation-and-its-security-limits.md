---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Process Isolation And Its Security Limits

The `scout` application runs in a Linux container. A container is a process or group of processes packaged and run with isolation and resource controls. It does not need its own complete operating system kernel. Linux containers on the same host normally use the host kernel.

Linux namespaces provide separate views of selected system resources. A process can see a different process identifier list, network stack or mount layout from another process. Namespace here is a Linux isolation mechanism, which differs from a Kubernetes namespace used to scope application programming interface (API) resources.

Control groups, commonly called cgroups, account for and constrain resource use by groups of processes. They support mechanisms such as central processing unit (CPU) time limits and memory enforcement. Namespaces change what a process can see; cgroups govern aspects of how many resources it can use. Neither removes the need to configure privileges correctly.

A virtual machine presents virtual hardware and normally runs its own guest kernel. This creates a different isolation boundary and has its own startup and resource overhead. Containers can run inside virtual machines, so the two technologies are often combined rather than used as mutually exclusive options.

Container security depends on the shared kernel, runtime configuration, application behavior and host protections. A privileged container or extensive host mounts can weaken the intended boundary. Root inside a container is not automatically safe merely because the application is packaged in an image.

Choose an isolation model from the workload and trust requirements. Lightweight startup favors containers for many applications. A stronger separate-kernel boundary can favor virtual machines for some workloads. Neither choice automatically supplies all network, storage and identity protections.

## Separating Visibility From Resource Enforcement

A process namespace can limit which process identifiers an application sees, while a mount namespace changes its filesystem view. A network namespace can provide its own interfaces and port space. These mechanisms isolate selected views; they do not automatically assign a dedicated processor or a private kernel.

Cgroups address another question: how much resource use a process group is allowed and how usage is accounted. A container can have a limited CPU allowance while sharing the host kernel with several others. If an application is CPU-throttled, changing its process namespace is not the relevant remedy. The resource boundary, workload demand and configured limit need analysis.

Filesystem isolation also depends on mounts and permissions. Exposing a host directory can give a container access outside its image's normal view. A read-only mount narrows possible changes but still exposes its readable contents. A privileged workload can weaken other protections through capabilities and host access.

## Comparing Two Deployment Boundaries

Consider an untrusted customer workload and an internal stateless API. Both can be packaged as container images. The untrusted workload may justify a separate-kernel or sandboxing boundary because consequences of a shared-kernel flaw are part of the threat model. The internal API may favor ordinary containers with scoped privileges and host hardening. Packaging alone does not decide the trust boundary.

A virtual machine normally runs a guest operating system kernel on virtual hardware. It still needs patching, credential controls and network policy. Stronger isolation in one layer does not eliminate risks in application code or shared external services.

Container and virtual-machine approaches can be combined: a cluster's workers can be virtual machines, with several containers on each. In that arrangement, applications on one worker still share that worker's kernel, even though workers have separate guest kernels. State the actual boundary in the design rather than treating “in the cloud” or “in a container” as a complete isolation description.

## Common pitfalls

> [!WARNING]
> Linux namespaces and Kubernetes namespaces have different purposes. Containers normally share a host kernel; packaging does not automatically create a virtual machine boundary.

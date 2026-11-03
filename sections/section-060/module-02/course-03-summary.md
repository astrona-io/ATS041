---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Summary

A flaw in application code gives an attacker a process with the rights that the pod granted. The settings in the `securityContext` decide how much that process can do. A non-root user, dropped capabilities, `allowPrivilegeEscalation: false` and a read-only root file system remove the usual next steps after a break-in: changing system files, installing tools and becoming root. A `seccompProfile` of `RuntimeDefault` filters system calls, and it is not applied unless the pod or the kubelet configuration sets it. The kernel enforces every one of these settings, so the process itself can show them in `/proc/self/status`.

A container that needs to write gets a volume at the path it needs, not a writable root. A named image user needs a numeric `runAsUser` before the kubelet accepts `runAsNonRoot`. A privileged container ignores the point of the other settings and does not belong in an application namespace.

Resource settings bound how much of a node a workload can use. A request is what the scheduler reserves, and a limit is the most the container may use. A container above its CPU limit is throttled. A container above its memory limit is killed with the reason `OOMKilled`. The three quality of service classes, `Guaranteed`, `Burstable` and `BestEffort`, decide which pods are evicted first. A LimitRange gives containers default values at admission and a ResourceQuota caps the totals of a namespace, and a quota on memory needs values on every pod. A quota with no margin blocks rolling updates.

Limits protect availability. They do not protect data, and they do not make repeated or expensive operations safe. The application code must still bound request size, time and concurrency, and Job fields such as `backoffLimit`, `activeDeadlineSeconds` and `concurrencyPolicy: Forbid` limit repetition of batch work.

The key facts to remember are these:

- `allowPrivilegeEscalation: false` sets the kernel flag `no_new_privs`.
- Dropping `ALL` capabilities and adding back only what is needed is the least-privilege pattern.
- Memory is killed at its limit, processor time is throttled.
- A LimitRange applies to new pods only.

<!-- astrona:playground:destroy -->

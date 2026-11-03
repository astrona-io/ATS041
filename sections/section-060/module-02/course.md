---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Containing A Compromised Workload

Assume that an attacker finds a flaw in the code of one pod and runs commands inside it. What can the attacker do next? The answer depends on the settings of the container and on the limits of the namespace. This module shows which pod settings reduce what a compromised process can do, and which resource settings stop one workload from using the whole node or the whole namespace.

## Learning objectives

After this module you can:

- Explain what `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation`, `capabilities` and `seccompProfile` change for a process that an attacker controls.
- Check these settings inside a running container.
- Write a `securityContext` that applies them to a Deployment and give writable space only where the application needs it.
- Explain requests, limits and the three quality of service classes, and what happens when a container exceeds its memory limit.
- Use a LimitRange to give containers default values and a ResourceQuota to cap a namespace.
- Explain why resource limits protect availability but do not stop an attack on the data.

## What to know first

You need pods, Deployments, namespaces and the commands `kubectl apply`, `kubectl exec` and `kubectl get -o jsonpath`. You need no policy engine.

## The order of the parts

The first part covers container settings that limit a compromised process: user, file system, capabilities, privilege escalation and system call filtering. The second part covers resource requests, limits, LimitRange and ResourceQuota, which bound the share of the node that one workload can use.

## The playground

Your playground is a single-node `kind` cluster running Kubernetes 1.35 with no extra tools.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The example workloads `scout`, `probe` and `shuttle`. A Deployment `loose-agent` that runs with no security settings and a Deployment `tight-agent` that uses all the settings from the first part. No LimitRange and no ResourceQuota |
| `outpost` | The `drifter` curl client |

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->

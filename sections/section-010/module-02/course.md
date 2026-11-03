---
exam_objectives:
  - The 4Cs of Cloud Native Security
---
# Defense In Depth: Preventive, Detective And Corrective Controls

No single control stops every attack, and any control can fail or be misconfigured. Defense in depth is the design answer: several independent controls cover the same threat, so one failure does not decide the outcome. The Kubernetes and Cloud Native Security Associate (KCSA) exam expects you to sort controls by purpose (preventive, detective, corrective) and to place them on the four layers: cloud, cluster, container and code.

Keep one sentence in mind for this module: **a preventive control blocks an action, a detective control records or reports it, and a corrective control restores a safe state after it.** You will add one control of each kind to a namespace, and see what each one does and does not do.

The module has three parts. The first covers preventive controls: what the API server refuses at admission, with Pod Security Admission as the worked example. The second covers detective controls: what the cluster reports and records, and what it leaves unrecorded unless an administrator turns it on. The third covers corrective controls: containment and recovery, such as deleting an unmanaged pod and rolling back a failed change.

## Learning objectives

After this module you can:

- Classify a control as preventive, detective or corrective, and give an example at each of the cluster and container layers.
- Enforce a Pod Security level on a namespace and show that the API server rejects a violating pod.
- Explain why enforcement does not remove pods that were already running.
- Use the audit and warn modes to find violations without blocking them.
- Contain an unmanaged pod and roll back a failed Deployment change.

## Before you start

You need Kubernetes basics: namespaces, Deployments, pods and the commands `kubectl get`, `kubectl label` and `kubectl delete`. You need no extra tools.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. It has these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application, each on a service account of the same name |
| `outpost` | `drifter` | A client that belongs to another team |
| `outpost` | pod `intruder` | A privileged pod that no Deployment manages, on purpose |

Neither namespace has Pod Security labels yet. You run every command as the cluster administrator. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->

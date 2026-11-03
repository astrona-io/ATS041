---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Summary

A Kubernetes cluster starts as a flat network. Every pod can reach every other pod until a NetworkPolicy selects it. A NetworkPolicy lists allowed ingress or egress traffic for the pods it selects. Policies only add allow rules, so a default deny policy with an empty pod selector and no rules comes first, and specific allow policies follow. The port in a rule is the container port. A peer that holds both a namespace selector and a pod selector requires both, while separate peers are alternatives. The network plugin enforces policies, and a policy has no effect on a plugin that does not support it. An egress policy needs a rule for DNS.

Resource use is a separate segment. A request is the amount the scheduler reserves and a limit is the maximum a container may use. A LimitRange gives defaults and bounds to containers when a pod is created. A ResourceQuota caps the totals of a namespace and rejects requests that exceed them with a `403 Forbidden` error. Neither object changes pods that already exist, and a quota on requests and limits needs pods that state them or a LimitRange that fills them in.

Identity is another segment. Each workload should have its own service account with only the rights it needs, and a workload that does not call the API should not mount a token.

When workloads do not trust each other, the shared kernel is the weakness. A RuntimeClass names a sandboxed runtime that the node must provide. Taints keep other pods away from a node, node selectors keep a tenant on its nodes, and tolerations let a pod onto a tainted node. A toleration is chosen by whoever writes the pod, so an admission control must limit it. A separate cluster is the strongest split and still can share cloud accounts and external services. The key facts to remember are these:

- Policies are additive; there is no deny rule.
- A NetworkPolicy does nothing without an enforcing network plugin.
- Existing pods keep their settings when a quota or LimitRange is added.
- State what a boundary still shares instead of calling a design isolated.

<!-- astrona:playground:destroy -->

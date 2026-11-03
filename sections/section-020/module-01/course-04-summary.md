---
draft: true
exam_objectives:
  - Cloud Provider and Infrastructure Security
---
# Summary

Shared responsibility follows the service agreement. A provider always owns the facilities, hardware and virtualization. In a managed service it also runs the control plane and sometimes the nodes. The customer always owns the decision about who may reach the API endpoint, which identities may act, and which code and data run. A responsibility matrix asks who configures, patches, monitors and recovers each control, and every unanswered question is a gap.

Identities exist in the cloud account and in the cluster, and they are separate permission systems. Pipelines, people, machines and pods each need their own identity with the least privilege that the job requires. The blast radius of an identity is the set of assets it can affect if it leaks. A narrow Role bound in one namespace replaces a cluster-wide grant, and `kubectl auth can-i --as` measures the difference.

A pod receives a service account token by default. Setting `automountServiceAccountToken: false` removes the projected token volume from pods that never call the API. Changes to a pod template reach only new pods, so a rollout must finish before the change counts.

The instance metadata service answers at a link-local address, `169.254.169.254`, and can return the node's role credentials to any pod on the node. Cloud settings such as a session-oriented metadata version, a low hop limit and a minimal node role are the main defense. A NetworkPolicy with an `ipBlock` and an `except` entry adds a Kubernetes-side block, and it works only when the network plugin enforces policies.

Key facts to remember:

- Network restriction, authentication and authorization protect different stages of the same request.
- A managed control plane does not limit what a valid but over-privileged credential can do.
- Least privilege applies to people, pipelines, nodes and pods alike.
- Removing a token or a binding does not undo what a leaked credential already did, so revoke and rotate it.

<!-- astrona:playground:destroy -->

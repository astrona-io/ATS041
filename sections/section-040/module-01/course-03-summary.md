---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Summary

Process and virtual-machine isolation protect different boundaries. Namespaces, capabilities, system-call restrictions and resource controls limit selected behaviors, while privileges and host access can weaken containment.

Kubernetes namespace scoping is distinct from kernel, network and management separation. Match the boundary to workload trust and consider what a compromised process can still do through legitimate credentials and dependencies. Segmentation requires explicit controls and known administrative ownership.

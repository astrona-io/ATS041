---
draft: true
exam_objectives:
  - Controls and Frameworks
---
# Summary

A threat is something that can cause harm. A vulnerability is the weakness that lets it succeed. Risk combines likelihood and impact in a real environment, and a security control is a measure that reduces that risk. A written policy states a rule, but only a control enforces it or makes a violation visible.

Controls differ by purpose. A preventive control stops the action, a detective control records or reports it, and a corrective control limits the damage or restores a good state. Pod Security Admission shows all of this with one label format: `enforce` rejects a pod, `warn` returns a warning, and `audit` writes an audit annotation. Enforcing a level never removes pods that already run, so removal is a separate corrective action.

Frameworks organize control goals. Examples are the NIST Cybersecurity Framework, PCI DSS, NIST SSDF and SLSA. A benchmark such as the CIS Kubernetes Benchmark lists specific configuration checks. Each framework entry becomes a control objective, a control and evidence, and evidence from the live API is stronger than evidence from a manifest file. Some benchmark items concern node files and processes, so the API cannot show them.

Threat modeling lists what can go wrong. STRIDE names six categories: spoofing, tampering, repudiation, information disclosure, denial of service and elevation of privilege. After ranking a risk, a team can mitigate, avoid, transfer or accept it. Whatever remains is residual risk. An accepted risk needs an owner, a reason, a review date and a compensating detective control.

The key facts to remember are these:

- A policy is not a control, and a passed check is bounded evidence.
- `enforce` prevents, `warn` and `audit` detect, and deleting a workload corrects.
- Frameworks say what to cover, and benchmarks say how to check one product.
- Residual risk never reaches zero, and every exception needs an owner.

<!-- astrona:playground:destroy -->

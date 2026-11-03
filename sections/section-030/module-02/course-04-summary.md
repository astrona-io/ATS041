---
draft: true
exam_objectives:
  - Controls and Frameworks
---
# Summary

Admission is the step in the Kubernetes API server that runs after authentication and authorization and before an object is stored. Mutating admission can change a request and validating admission can only accept or reject it. RBAC decides who may act, while admission decides whether the content of the request is acceptable. A rule in validating admission applies to every client.

A ValidatingAdmissionPolicy is a built-in, generally available feature. The policy holds the match constraints and CEL expressions that return false for a violation. A ValidatingAdmissionPolicyBinding gives the policy a scope and an effect. A policy without a binding does nothing. The error of a rejected request names both the policy and the binding.

The `validationActions` of a binding choose the effect. `Deny` rejects the request, `Warn` returns a warning to the client and `Audit` records the failure in the audit event. `Deny` and `Warn` cannot be combined. A safe rollout starts with `Audit`, moves to `Warn` and ends with `Deny` together with `Audit`. A namespace selector limits the scope, and a label can mark an explicit exception.

A control has edges. A policy checks only the requests it matches, so a rule on Deployments does not see bare pods or StatefulSets. A binding checks requests, not stored objects. Whoever can edit the policy or the binding can switch the control off. Test one request that must fail and one that must pass, collect the state with `kubectl` and `jq`, and write down the residual risk.

The key facts to remember are these:

- Policy plus binding gives an effect. Either one alone gives none.
- The actions are `Deny`, `Warn` and `Audit`, and `Deny` and `Warn` do not combine.
- Existing objects are not re-checked until they change.
- Protect the control itself with RBAC and name what it does not see.

<!-- astrona:playground:destroy -->

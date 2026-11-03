# Question

Solve this question on: `terminal`

The fleet security team wrote the rule "every container of a Deployment in `starfleet` must set a memory limit" and installed it as the ValidatingAdmissionPolicy `require-memory-limits` with the binding `require-memory-limits-binding`. A review found that the control does not work: a Deployment without a memory limit is still created in `starfleet`, and the `probe` Deployment still has no limit.

1. Make the binding block violations. It must reject a request that fails the policy, and it must keep recording failures in the audit log.

2. Bring `starfleet` into the scope of the binding. Use the namespace label that the binding already selects.

3. Correct the policy so that it checks the right field. A Deployment whose containers set `resources.limits.memory` must be accepted, and a Deployment that sets only `resources.requests.memory` must be rejected.

4. Change the `probe` Deployment so that its container sets a memory limit. Every replica of `scout`, `probe` and `shuttle` must be available. Do not delete or scale down a Deployment.

Do not change the `outpost` namespace and do not bind the policy to every namespace. A Deployment without a memory limit must still be accepted in `outpost`. `kubectl` already points at the cluster as the cluster administrator.

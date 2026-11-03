# Question

Solve this question on: `terminal`

A new team moves into the namespace `orbit`. The fleet security standard says: a team namespace must enforce the `baseline` Pod Security level and report violations of the `restricted` level, no privileged workload may run in it, every Deployment in it must set a memory limit, and a workload that never calls the Kubernetes API must not mount a service account token. The ValidatingAdmissionPolicy `require-memory-limits` exists in the cluster, but no binding applies it. The team already runs a `relay` Deployment without a memory limit and a privileged `beacon-debug` Deployment.

1. Set the Pod Security labels on `orbit`: `enforce` at `baseline`, and `warn` and `audit` at `restricted`.

2. Remove the privileged workload from `orbit`. A privileged pod must be rejected there afterwards.

3. Create a ValidatingAdmissionPolicyBinding for `require-memory-limits` that denies violations in `orbit` and only in `orbit`. Select the namespace with its automatic name label.

4. Change the `relay` Deployment so that its container sets a memory limit and its pods do not mount a service account token. It must stay available.

Do not label or bind `starfleet` or `outpost`, and do not change `scout`. A Deployment without a memory limit must still be accepted in `starfleet` and in `outpost`. `kubectl` already points at the cluster as the cluster administrator.

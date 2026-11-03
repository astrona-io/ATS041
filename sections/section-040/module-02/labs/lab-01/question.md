# Question

Solve this question on: `terminal`

The namespace `depot` was created for a new team. It runs the backend `ledger` (container port 8080, behind a Service on port 80) and the client `loader`. Nothing separates `depot` from the rest of the cluster. The `shuttle` client in `starfleet` must keep using `ledger`. Segment the namespace.

Meet all of these requirements in the namespace `depot`. Do not change the Deployments, the Services or the images.

1. Add a default deny ingress policy: a NetworkPolicy that selects every pod in `depot`, applies to ingress and allows nothing.
2. Add a NetworkPolicy that lets the pods labeled `app: ledger` accept ingress only from (a) the pods labeled `app: loader` in `depot` and (b) the pods labeled `app: shuttle` in the namespace `starfleet`, and only on TCP port 8080. Source (b) must be one peer that requires both the namespace and the pod label. No other source and no other port may be allowed.
3. Add a ResourceQuota with `pods` at most `10` and values for `requests.cpu`, `requests.memory` and `limits.memory`.
4. Add a LimitRange of type `Container` that sets a default memory limit (`default`), a default CPU request and memory request (`defaultRequest`) and a maximum memory (`max`). A pod created without resources must be admitted.
5. The service accounts `ledger` and `loader` must not mount a token (`automountServiceAccountToken: false`).

`kubectl` already points at the cluster as the cluster administrator. The grader reads the objects; it does not need your network plugin to enforce the policies.

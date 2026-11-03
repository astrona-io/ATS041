# Summary

Admission is the step inside the API server that can reject a request after authorization and before storage. A `ValidatingAdmissionPolicy` writes a validating rule in the Common Expression Language, and a `ValidatingAdmissionPolicyBinding` chooses the scope and the action. The actions are `Deny`, `Warn` and `Audit`. A policy without a binding does nothing, and `failurePolicy: Fail` rejects a request when the rule cannot be evaluated.

An approved-registry rule tests the image prefix of every container and init container of a pod. Each prefix ends with a slash so that look-alike names do not match. The rule checks pods only. A Deployment is accepted, and its ReplicaSet then fails to create the pods and records `FailedCreate` events. Existing pods keep running until they are recreated.

A digest rule tests that the image ends with `@sha256:` and 64 hexadecimal characters. It checks the shape only: it does not check that the digest is approved. A strict rule is introduced in steps, with `Warn` and `Audit` first, then `Deny`, and bindings select application namespaces so that system namespaces keep working.

A signature binds an identity to a digest, and an attestation is a signed statement about it, such as provenance or a scan result. Signature checks need a component that can reach the registry, so they run in an admission webhook or the `ImagePolicyWebhook` plugin, not in a `ValidatingAdmissionPolicy`. A webhook outage with `failurePolicy: Ignore` skips the check. A scan finds known problems only, so scanning must also cover stored and running images.

Key facts to remember:

- RBAC decides who may create a pod; admission decides whether the pod is acceptable.
- `Warn` and `Audit` admit the request; only `Deny` rejects it.
- A digest rule checks the format, not the approval.
- A `ValidatingAdmissionPolicy` cannot verify a signature.
- A reviewer matches each failure to the step of the image path where it entered.

<!-- astrona:playground:destroy -->

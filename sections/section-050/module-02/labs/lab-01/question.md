# Question

Solve this question on: `terminal`

The dockyard team may only run images from two approved places, and the platform team has not enforced it yet. The namespace `dockyard` holds the Deployment `stray`, which uses an image from `docker.io`. The namespace `outpost` belongs to another team. Enforce the rule with a `ValidatingAdmissionPolicy`. Do not delete `stray` and do not install any extra tool.

1. Create a `ValidatingAdmissionPolicy` named `approved-registries` for the resource `pods` (API group `""`, version `v1`, operations `CREATE` and `UPDATE`). Every image of every container must start with `registry.starfleet.example/` or with `ghcr.io/stefanprodan/`. Both prefixes end with a slash. Use `failurePolicy: Fail`.

2. Init containers must follow the same rule. A pod with an approved main container and an unapproved init container must be rejected.

3. Create a `ValidatingAdmissionPolicyBinding` for the policy that has the action `Deny` and applies to the namespace `dockyard` only. Pods in `outpost` and in every other namespace must still be admitted with any image.

Image names that only look similar, such as `registry.starfleet.example.attacker.test/app:1`, must be rejected.

`kubectl` already points at the cluster as the cluster administrator. A server-side dry run, `kubectl create --dry-run=server -f pod.yaml`, shows whether a pod would be admitted.

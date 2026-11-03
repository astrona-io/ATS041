# Question

Solve this question on: `terminal`

The shipyard team onboards a new namespace, `shipyard`. Its Deployments `cargo` and `tug` run as the service account `loader` and are scaled to zero replicas on purpose, so no image is pulled. Make the namespace follow the supply chain rules of the platform. Do not scale the Deployments.

1. The Deployment `cargo` runs the container `cargo` with `ghcr.io/stefanprodan/podinfo:latest`. The ConfigMap `release-record` in `shipyard` holds the approved digest in the key `cargo-digest`. Change the image to the same repository, referenced by that digest, with no tag.

2. Pods in `shipyard` pull from `registry.starfleet.example`. Create the Secret `registry-creds` in `shipyard` with the type `kubernetes.io/dockerconfigjson`, the server `registry.starfleet.example`, the user name `cargo-puller` and the password `s3al-pull-4410`. Give it to the pods through the service account `loader`. No Deployment may list `imagePullSecrets` itself.

3. Create a `ValidatingAdmissionPolicy` named `require-image-digest` for `pods` (operations `CREATE` and `UPDATE`, `failurePolicy: Fail`). Every container and every init container must reference its image by digest: the image must end with `@sha256:` followed by 64 hexadecimal characters.

4. Bind the policy with a `ValidatingAdmissionPolicyBinding` that has the action `Deny` and applies to the namespace `shipyard` only. Pods that use a tag only must still be admitted in `outpost` and in `kube-system`.

`kubectl` already points at the cluster as the cluster administrator.

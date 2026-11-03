# Question

Solve this question on: `terminal`

The security team reviews the `starfleet` namespace of a self-managed cluster. The `scout` and `probe` workloads never call the Kubernetes API, yet every pod receives a service account token. The pipeline identity `build-runner` in `starfleet` is bound to `cluster-admin`, although it only updates Deployments. No policy keeps pods away from the cloud instance metadata address `169.254.169.254`.

1. Change the Deployments `scout` and `probe` in `starfleet` so that their pods receive no service account token. Every replica must be available after the change.

2. Create a NetworkPolicy in `starfleet` that selects all pods and limits egress so that it allows traffic to every IPv4 address except `169.254.169.254`. Other traffic, such as DNS and requests between Services, must keep working.

3. Remove the `cluster-admin` binding from the service account `build-runner`. Give it a Role in `starfleet` that allows only `get`, `list`, `patch` and `update` on Deployments, with a RoleBinding. The identity must not be able to delete Deployments, to act in other namespaces, or to read Secrets.

Do not change the `outpost` namespace, and do not delete or scale down a Deployment. `kubectl` already points at the cluster as the cluster administrator.

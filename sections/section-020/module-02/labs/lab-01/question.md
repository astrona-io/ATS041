# Question

Solve this question on: `terminal`

An audit of a self-managed cluster finds four exposure paths in the `starfleet` namespace. A `ClusterRoleBinding` gives the `view` ClusterRole to unauthenticated callers. A Deployment called `node-inspector` mounts a directory of the node. The namespace has no Pod Security labels. The service account `scout` can read every Secret in `starfleet`, although it only needs the ConfigMap `fleet-settings`.

1. Remove the binding that gives the `view` ClusterRole to the group `system:unauthenticated`. Keep the built-in bindings of the cluster.

2. Remove the `node-inspector` Deployment, and enforce the `baseline` Pod Security Standards level on `starfleet` with the namespace label `pod-security.kubernetes.io/enforce`. A pod that mounts a host path must then be rejected.

3. Change the permissions of the service account `scout` so that it can `get` the ConfigMap `fleet-settings` in `starfleet` and cannot read any Secret there.

The Secret `drive-credentials` and the Deployments `scout`, `probe` and `shuttle` must stay. Do not change the `outpost` namespace. `kubectl` already points at the cluster as the cluster administrator.

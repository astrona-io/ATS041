# Question

Solve this question on: `terminal`

The `outpost` namespace of a self-managed cluster is going into production, and the security review lists five findings. The `drifter` client receives a service account token it never uses. Its service account is bound to `cluster-admin`. Nothing stops pods from calling the cloud metadata address `169.254.169.254`. A binding gives the `view` ClusterRole to unauthenticated callers. A Deployment called `drifter-hostmount` mounts a directory of the node, and the namespace has no Pod Security labels.

1. Make the `drifter` pods run without a service account token. The `drifter` Deployment must stay available.

2. Remove the `cluster-admin` binding of the `drifter` service account. Give it a Role in `outpost` that allows only `get` and `list` on ConfigMaps. It must not read Secrets or act cluster-wide.

3. Create a NetworkPolicy in `outpost` that selects all pods and allows egress to every IPv4 address except `169.254.169.254`.

4. Remove the binding that gives the `view` ClusterRole to the group `system:unauthenticated`. Keep the built-in bindings of the cluster.

5. Remove the `drifter-hostmount` Deployment and enforce the `baseline` Pod Security Standards level on `outpost`. A pod that mounts a host path must then be rejected.

Do not delete the `drifter` Deployment or the Secret `outpost-key`. `kubectl` already points at the cluster as the cluster administrator.

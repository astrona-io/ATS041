# Question

Solve this question on: `terminal`

A review of the `starfleet` namespace found weaknesses in three of the four layers. The `shuttle` pod runs on a service account with full cluster rights, the `scout` container runs privileged with a node directory mounted, and `shuttle` receives an API token it never uses. Fix them with `kubectl`. Do not change `probe` or `drifter`, and do not delete any service account.

1. The service account `shuttle` in `starfleet` is bound to the `cluster-admin` ClusterRole. Remove that grant. `shuttle` needs no Kubernetes API rights.

2. The `shuttle` Deployment must not receive a service account token. Make its pods start without the token volume.

3. The `scout` Deployment runs a privileged container and mounts the node directory `/etc` through a `hostPath` volume. Remove both. The `scout` container must also set `allowPrivilegeEscalation` to `false`, drop all Linux capabilities, and run as a non-root user.

4. After your changes, `scout` must be rolled out and ready.

`kubectl` already points at the cluster as the cluster administrator. You can check any identity with `--as`.

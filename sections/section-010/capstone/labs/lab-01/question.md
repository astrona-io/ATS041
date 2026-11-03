# Question

Solve this question on: `terminal`

A new team namespace `relay` is about to go live. Its `beacon` workload was copied from a test cluster and carries weaknesses in the cluster, container and code-facing settings, and a leftover pod sits in the namespace. Bring `relay` to a safe state with `kubectl` only. The `beacon` Deployment must keep serving, and you must not delete the namespace, the `beacon` Deployment or any service account.

1. The service account `beacon` is bound to the `cluster-admin` ClusterRole. Remove that grant. `beacon` needs no Kubernetes API rights.

2. `beacon` pods must start without a service account token.

3. The `beacon` container runs privileged as root and mounts the node directory `/etc` through a `hostPath` volume. Change the Deployment so it meets the settings of the `restricted` Pod Security level: no privileged mode, no host path volume, `runAsNonRoot` with a non-zero user, `allowPrivilegeEscalation` set to `false`, all capabilities dropped and the `RuntimeDefault` seccomp profile.

4. Make the API server reject any new pod in `relay` that violates the `restricted` level.

5. The pod `stray` in `relay` is privileged and no Deployment manages it. Remove it. After all changes, `beacon` must be rolled out and ready.

`kubectl` already points at the cluster as the cluster administrator.

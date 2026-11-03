# Question

Solve this question on: `terminal`

The Starfleet engineering team has moved the `beacon` service into a new namespace called `orbit`. A review before launch found problems in the code and workload layer. The token that `beacon` uses to call its partner is written into the pod template, the container has no restrictions, nothing limits its memory, and its service account can read every Secret even though `beacon` never calls the Kubernetes API. Fix the problems with `kubectl`. Keep the image, the Service and the service account `beacon`.

1. Read the value of the `API_TOKEN` variable in the `beacon` pod template. Create a Secret named `beacon-credentials` in `orbit` with the key `token` and that value. The `beacon` container must receive `API_TOKEN` from that Secret through `secretKeyRef`, and the pod template must have no literal token.

2. Harden the `beacon` container. The pod must run as the non-root user `65532` with `runAsNonRoot: true` and the `RuntimeDefault` seccomp profile. The container must set `allowPrivilegeEscalation: false` and `readOnlyRootFilesystem: true`, and must drop all Linux capabilities.

3. Set a memory request and a memory limit on the `beacon` container. Then create a ResourceQuota named `orbit-quota` in `orbit` that allows at most `5` pods and a total memory limit of `512Mi` (`limits.memory`).

4. `beacon` must not read Secrets or receive an API token. Remove the permission that lets the `beacon` service account read Secrets, and make the pods start without a service account token.

5. After your changes, `beacon` must be rolled out and its Service `beacon` must have a ready endpoint.

`kubectl` already points at the cluster as the cluster administrator.

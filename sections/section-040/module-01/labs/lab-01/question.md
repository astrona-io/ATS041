# Question

Solve this question on: `terminal`

The team that owns the `drifter` client in `outpost` added a second client, the Deployment `relay`. A review found that it was written with the settings of a node debugging tool, but it only sends HTTP requests with `curl`. Remove the host access from `relay` without breaking it.

The Deployment `relay` in `outpost` must meet all of these requirements:

1. The pod template must not share any host namespace: `hostPID`, `hostNetwork` and `hostIPC` must be `false` or not set.
2. The `relay` container must not be privileged. It must set `allowPrivilegeEscalation` to `false`, drop all Linux capabilities (`drop: ["ALL"]`), add no capability back, and use a read-only root filesystem (`readOnlyRootFilesystem: true`).
3. The pod template must not have a `hostPath` volume, and no container may mount one.
4. The pods must not receive a service account token. Set the field on the pod template (the pod field takes precedence over the service account field).
5. Keep the Deployment `relay`, its label `app: relay`, its service account `relay`, its image `curlimages/curl:8.22.0` and its command. The new pod must be running, so wait for the rollout to finish.

Do not delete the namespace and do not create a second Deployment. `kubectl` already points at the cluster as the cluster administrator.

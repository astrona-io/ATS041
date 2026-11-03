# Question

Solve this question on: `terminal`

A review of the `starfleet` namespace found that a compromised `probe` pod would run as it likes and that nothing limits how much memory the namespace may reserve. `probe` is a Go service that listens on port `8080` and writes no files. Fix this with `kubectl`. Do not change `scout`, `shuttle` or `drifter`.

1. Change the `probe` Deployment so that its pod runs as the non-root user `65532` with `runAsNonRoot: true` and the `RuntimeDefault` seccomp profile. The `probe` container must set `allowPrivilegeEscalation: false` and `readOnlyRootFilesystem: true`, and must drop all Linux capabilities. Keep the image and the port.

2. Create a LimitRange named `container-defaults` in `starfleet`. It has one limit of type `Container` that gives every container a default memory request of `32Mi` and a default memory limit of `64Mi`.

3. Create a ResourceQuota named `starfleet-quota` in `starfleet` that allows at most `10` pods and a total memory limit of `1Gi` (`limits.memory`).

4. After your changes, `probe` must be rolled out and ready. A new pod without a `resources` field must still be admitted in `starfleet`, and a pod that asks for a memory limit of `2Gi` must be rejected.

`kubectl` already points at the cluster as the cluster administrator.

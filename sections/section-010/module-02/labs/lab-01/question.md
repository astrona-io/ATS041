# Question

Solve this question on: `terminal`

The `drifter` pod in `outpost` must keep running, but a review found that `outpost` has no admission control and still contains a privileged pod that no Deployment manages. In `starfleet`, a rollout of `probe` to a new image failed and the Deployment is stuck. Add the missing controls and recover. Use `kubectl` only. Do not delete the `drifter` Deployment, any namespace, or the `probe` Deployment.

1. Preventive control: make the API server reject new privileged pods in `outpost`. Use the Pod Security Admission label for the `baseline` level in enforce mode.

2. Detective control: make `outpost` also record and warn about pods that do not meet the `restricted` level, without blocking them.

3. Corrective control (containment): the pod `intruder` in `outpost` is privileged and no Deployment manages it. Remove it.

4. Corrective control (recovery): the Deployment `probe` in `starfleet` points at an image tag that does not exist. Return it to the previous working revision.

`kubectl` already points at the cluster as the cluster administrator.

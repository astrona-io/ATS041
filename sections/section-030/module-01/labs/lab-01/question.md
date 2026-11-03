# Question

Solve this question on: `terminal`

The security policy of the fleet says: "No privileged pod may run in `starfleet`, every violation must be visible, and a workload that never calls the Kubernetes API must not hold an API token." An audit found that the cluster does none of this. The `starfleet` namespace has no Pod Security labels, a Deployment called `debug-tools` runs a privileged container, and the `shuttle` pods mount a service account token although `shuttle` is only a client of the `scout` Service.

1. Add the preventive control: enforce the `baseline` Pod Security Standards level on `starfleet` with the namespace label `pod-security.kubernetes.io/enforce`.

2. Add the detective controls: warn and audit at the `restricted` level on `starfleet` with the labels `pod-security.kubernetes.io/warn` and `pod-security.kubernetes.io/audit`.

3. Take the corrective action: remove the `debug-tools` Deployment. A privileged pod must be rejected in `starfleet` afterwards.

4. Change the `shuttle` Deployment so that its pods do not mount a service account token. Every `shuttle` replica must be available after the change.

Do not change the `outpost` namespace, and do not delete or scale down `scout`, `probe` or `shuttle`. `shuttle` must still get an answer from the `scout` Service. `kubectl` already points at the cluster as the cluster administrator.

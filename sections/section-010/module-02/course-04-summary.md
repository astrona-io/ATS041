---
exam_objectives:
  - The 4Cs of Cloud Native Security
---
# Summary

Defense in depth places several independent controls on the same threat, so one failure does not decide the outcome. Controls are sorted by purpose. A preventive control blocks an action before it takes effect. A detective control records or reports an action. A corrective control contains the damage and restores a safe state. Each control also sits on a layer, and a control only covers what its layer governs.

Pod Security Admission is a preventive control at the cluster layer that protects the container layer. A namespace label sets the level, and the API server rejects new pods that break it. The control checks pods at creation and update. It does not remove running pods, and it does not reject the Deployment that describes a violating pod.

Detection comes from several sources with different strength. The warn mode sends a message to the caller. The audit mode and the API server audit log keep a record for administrators, but only when audit logging is enabled. Events describe the lifecycle of an object for a short time. A query over the cluster state can find violations that already exist. A signal that nobody reads is not a control.

Correction has two forms. Containment limits the reach of a problem, and recovery restores a good state. A pod with an owner comes back after deletion, so containment changes its controller. An unmanaged pod is removed by deleting it. A rollback restores an earlier revision, and the result is only as safe as that revision.

Key facts:

- The enforce, audit and warn labels use the levels privileged, baseline and restricted.
- Enforcement acts at admission and leaves existing pods alone.
- Audit logging is not on by default and needs an audit policy on the API server.
- Contain first, then recover, and keep evidence when the incident needs it.

<!-- astrona:playground:destroy -->

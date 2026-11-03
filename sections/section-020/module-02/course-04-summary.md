---
exam_objectives:
  - Cloud Provider and Infrastructure Security
---
# Summary

Three controls guard the API endpoint, and they do not replace each other. The network path decides who can open a connection. Authentication decides who the caller is. Authorization decides what that identity may do. When anonymous authentication is enabled, a request without a credential becomes `system:anonymous` in the group `system:unauthenticated`, and the default rules allow it to read only a few public paths. A binding that names that group removes the credential requirement for its role, so the network path becomes the only control.

A node holds the kubelet credentials, the files of every pod on it and, on a control plane node, the manifests and certificates of the cluster. Access to a node is access to all of that. A `hostPath` volume mounts node files into a pod, and RBAC cannot stop it because RBAC does not read the pod specification. Pod Security Admission can: the `baseline` level forbids host path volumes, host namespaces and privileged containers. Namespace labels choose the level and the mode, and a server-side dry run tests a level before it is enforced.

The cluster keeps its state in etcd. Secrets are base64-encoded, not encrypted, and the API server stores them unencrypted unless encryption at rest is configured with `--encryption-provider-config`. The first provider in the `EncryptionConfiguration` encrypts new writes, and a KMS provider keeps the key outside the cluster. Encryption at rest protects the stored copy and the backups, but it does not stop a caller that RBAC lets read the Secret, so roles must name only the objects a workload needs. Disk encryption protects a stolen disk, and a running node still sees plain data.

Key facts to remember:

- A private endpoint does not authorize a caller, and RBAC does not hide a public endpoint.
- A namespace enforce label does not remove pods that already run.
- Base64 is encoding, not encryption.
- A backup or snapshot is a full copy of the cluster state, so its access and its keys need the same care as the live data.
- Losing an encryption key means losing the data it protects.

<!-- astrona:playground:destroy -->

---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Summary

Kubernetes decides which pods run, which identities they have and which pods may connect. The application code decides what each caller may read, what an input means and what an error reveals. A hardened pod can still return another user's data, and a platform control cannot repair a missing check in the code.

Untrusted input is any data a caller controls. The code validates it with an allow list, bounds its size, and keeps data apart from instructions with parameterized queries and path checks to prevent injection. Authentication proves who the caller is. Authorization decides what that caller may do with a specific object, and a missing check is broken access control. Responses and logs are output as well, so they must not carry credentials or internal detail. Safe repetition of a request needs an idempotency key in the application.

A credential must not live in an image, a pod template, a ConfigMap, an argument or a log. A Secret keeps it out of those places, but its values are only base64 encoded and are stored unencrypted unless encryption at rest is on. RBAC decides who may read a Secret, and the `list` and `watch` verbs expose every value. An environment variable is fixed when the container starts. A Secret volume is updated by the kubelet after the Secret changes, except when it is mounted with `subPath`.

Static analysis, dynamic analysis, software composition analysis, fuzzing and secret scanning each produce evidence about one aspect of the code. A software bill of materials lists the components in an image so a team can find affected images when a new vulnerability is published. A tag can move, and a digest identifies image content, so scan and signature results belong to a digest.

The key facts to remember are these:

- The platform delivers input unchanged. The code validates and authorizes.
- Base64 is an encoding and not encryption.
- A literal value in a pod template is readable by anyone who can read the Deployment.
- A clean scan means no known vulnerability was found, not that the code is safe.

<!-- astrona:playground:destroy -->

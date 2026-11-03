---
draft: true
exam_objectives:
  - Artifact Repository and Image Security
---
# Summary

A registry stores container images, and a private registry needs credentials. Kubernetes keeps them in a Secret of type `kubernetes.io/dockerconfigjson`, in the same namespace as the pod. The kubelet uses it to pull. A service account can carry the list of pull secrets, and the ServiceAccount admission controller copies it into each new pod. A Secret is only base64 encoded, so access control and encryption at rest protect it, and a pull-only registry account limits the damage of a leak.

A digest, a signature, provenance, a software bill of materials and a vulnerability scan answer different questions: which content, who vouches for it, how it was built, what it contains and which known problems it has. They only count when they describe the same digest that the cluster runs. A tag can be moved to other content, so a Deployment that must run verified content refers to the digest. The pull policy is set when the object is created and is not updated when the image changes, and the `imageID` in the pod status shows what actually ran.

What enters an image stays in its layers. A secret copied into a layer is leaked even if a later instruction deletes it. Multi-stage builds, small non-root base images, pinned and regularly rebuilt bases and locked dependencies reduce what an attacker can use. The build system holds the push credential and the signing key, so it is a trust boundary of its own.

Key facts to remember:

- A pull secret works only in its own namespace, and a service account can deliver it to every new pod.
- Base64 is encoding, not encryption.
- A digest names exact content, a tag is a movable label.
- A reference with a tag and a digest pulls by the digest.
- Deleting a file in a later layer does not remove it from the image.
- A signature proves who signed, not that the code is safe.

<!-- astrona:playground:destroy -->

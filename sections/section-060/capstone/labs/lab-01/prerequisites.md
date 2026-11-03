# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know how a pod receives a Secret, the container `securityContext` fields, memory requests and limits, ResourceQuota, and `kubectl auth can-i --as`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the `orbit` namespace. The commands for the lab are in the README of this folder.

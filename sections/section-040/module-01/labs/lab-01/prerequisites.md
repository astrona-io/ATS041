# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know what a pod `securityContext` is and which pod fields give a pod access to the node: `hostPID`, `hostNetwork`, `hostIPC`, `privileged` and `hostPath` volumes.

The lab starts a single-node kind cluster (Kubernetes 1.35) with one namespace, `outpost`, and one Deployment, `relay`. The commands for the lab are in the README of this folder.

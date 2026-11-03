# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know the host access fields of a pod spec, how a `NetworkPolicy` selects pods and peers, and how a `ResourceQuota` and a `LimitRange` work.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the namespace `annex`. The commands for the lab are in the README of this folder.

# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know the three Pod Security labels (`enforce`, `audit`, `warn`), the difference between a pod a Deployment manages and an unmanaged pod, and the command `kubectl rollout undo`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`. The commands for the lab are in the README of this folder.

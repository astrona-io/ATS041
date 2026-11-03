# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know how a `ValidatingAdmissionPolicy` and a `ValidatingAdmissionPolicyBinding` work, and how to test a request with `kubectl create --dry-run=server`.

The lab starts a single-node kind cluster (Kubernetes 1.35). It needs no extra tool and no internet access to a registry, because no pod in this lab has to start. The commands for the lab are in the README of this folder.

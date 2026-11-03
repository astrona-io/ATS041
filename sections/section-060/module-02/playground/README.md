# Containing A Compromised Workload — Playground

- **Slug:** ats-041-playground-060-02
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in
`outpost`) and two agents on the same image: `loose-agent` (root, no settings,
on purpose) and `tight-agent` (all container settings). No LimitRange and no
ResourceQuota. Nothing to submit.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/playground
astrona destroy ats-041-playground-060-02
```

`astrona destroy` takes the environment name, not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/containment.yaml` | The `loose-agent` and `tight-agent` Deployments |
| `docs/overview.md` | What the environment contains and ideas to try |

# Controlling Which Images Run — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-041-playground-050-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in `outpost`) and a `dockyard` namespace with Deployments that use images from different registries, scaled to zero, and no admission policy. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-02/playground
astrona destroy ats-041-playground-050-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/dockyard.yaml` | The `dockyard` namespace, its Deployments and the release record |
| `docs/overview.md` | What the environment contains and ideas to try |

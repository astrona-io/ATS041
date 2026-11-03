# Image References And Pull Credentials — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-041-playground-050-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in `outpost`) and a `dockyard` namespace with a `relay` Deployment that uses a mutable tag, a `hauler` Deployment on a service account without a pull secret, and a `release-record` ConfigMap. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/playground
astrona destroy ats-041-playground-050-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/dockyard.yaml` | The `dockyard` namespace, its Deployments and the release record |
| `docs/overview.md` | What the environment contains and ideas to try |

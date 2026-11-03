# Application Code And Workload Protection — Playground

- **Slug:** ats-041-playground-060-01
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in
`outpost`), a Secret `scout-db`, a `legacy-report` Deployment with a password
written into its pod template (on purpose), and a Role that lets `shuttle` read
every Secret in `starfleet` (on purpose). Nothing to submit.

Status: UNTESTED. Built and checked statically only (astrona validate, bash -n, YAML parse). Not booted.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/playground
astrona destroy ats-041-playground-060-01
```

`astrona destroy` takes the environment name, not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/credentials.yaml` | The Secret, `legacy-report`, and the Role and RoleBinding for `shuttle` |
| `docs/overview.md` | What the environment contains and ideas to try |

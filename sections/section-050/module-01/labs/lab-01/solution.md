# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written without running the lab, so the text does not show command output except where the Kubernetes behavior makes it certain.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `relay-and-hauler-otherwise-unchanged`. It stays your guard while you make the changes.

## Step 1: Pin relay to the recorded digest

Read the digest from the release record:

```sh
kubectl -n dockyard get configmap release-record -o jsonpath='{.data.relay-digest}'
```

The command prints a value that starts with `sha256:`. Put it after an `@` sign, and keep the repository. The container name is `relay`:

```sh
DIGEST=$(kubectl -n dockyard get configmap release-record -o jsonpath='{.data.relay-digest}')
kubectl -n dockyard set image deployment/relay "relay=ghcr.io/stefanprodan/podinfo@${DIGEST}"
```

The command prints `deployment.apps/relay image updated`. Check the result:

```sh
kubectl -n dockyard get deployment relay -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/labs/lab-01 --keep
```

The check `relay-pinned-by-digest` now passes. A tag together with the digest, or a digest copied from somewhere else, fails it.

## Step 2: Create the pull secret

`kubectl create secret docker-registry` builds a Secret of type `kubernetes.io/dockerconfigjson` for one registry:

```sh
kubectl -n dockyard create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=fleet-puller \
  --docker-password=d0ck-pull-7731
```

The command prints `secret/registry-creds created`. Check the type:

```sh
kubectl -n dockyard get secret registry-creds -o jsonpath='{.type}'
```

It prints `kubernetes.io/dockerconfigjson`. Grade it with the same `astrona submit ... --keep` command. The check `pull-secret-correct` now passes.

## Step 3: Attach the secret to the service account

Patch the service account, not the Deployment:

```sh
kubectl -n dockyard patch serviceaccount hauler -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'
```

The command prints `serviceaccount/hauler patched`. A new pod on this service account now receives the secret from the ServiceAccount admission controller. Check it with a server-side dry run, which creates nothing:

```sh
kubectl -n dockyard run probe-check --image=registry.starfleet.example/fleet/hauler:2.4 --overrides='{"spec":{"serviceAccountName":"hauler"}}' --dry-run=server -o jsonpath='{.spec.imagePullSecrets[*].name}'
```

It prints `registry-creds`. Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-01/labs/lab-01
```

All five checks pass. Finally remove the lab:

```sh
astrona destroy ats-041-lab-050-01
```

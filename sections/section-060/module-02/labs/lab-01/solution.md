# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01
```

Right after the start, `astrona submit` shows failing checks. The checks for the quota and the LimitRange fail because the objects do not exist, and the check `probe-hardened` fails because the template has no settings.

## Step 1: Harden the probe Deployment

A strategic merge patch changes the pod template and keeps the rest of the Deployment. The container name equals the Deployment name. Pod-level fields apply to all containers, and the container-level fields go in the `probe` entry:

```sh
kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"probe","securityContext":{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]}}}}'
kubectl -n starfleet rollout status deployment/probe
```

The first command prints `deployment.apps/probe patched`. If the new pod does not become ready, describe it and read the events. Then read the settings that the pod carries:

```sh
kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].spec.containers[0].securityContext}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01 --keep
```

The checks `probe-hardened` and `probe-available` now pass.

## Step 2: Create the LimitRange

Save this as `limitrange-container-defaults.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: starfleet
spec:
  limits:
    - type: Container
      defaultRequest:
        memory: 32Mi
      default:
        memory: 64Mi
```

Apply it:

```sh
kubectl apply -f limitrange-container-defaults.yaml
```

The command prints `limitrange/container-defaults created`. Then check the result and submit:

```sh
kubectl -n starfleet describe limitrange container-defaults
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01 --keep
```

The `describe` output lists the `Container` type with the default request and the default limit for memory.

## Step 3: Create the ResourceQuota

Create the quota after the LimitRange. A quota on `limits.memory` rejects every pod that has no memory limit, and the LimitRange supplies the limit. Save this as `resourcequota-starfleet.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: starfleet-quota
  namespace: starfleet
spec:
  hard:
    pods: "10"
    limits.memory: 1Gi
```

Apply it:

```sh
kubectl apply -f resourcequota-starfleet.yaml
```

The command prints `resourcequota/starfleet-quota created`. Then check the result:

```sh
kubectl -n starfleet describe resourcequota starfleet-quota
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01 --keep
```

The `describe` output shows the `Used` and `Hard` values for `pods` and `limits.memory`.

## Step 4: Prove the quota and finish

Save this as `pod-too-big.yaml`. It asks for a 2Gi memory limit, which is more than the quota allows:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: too-big
  namespace: starfleet
spec:
  serviceAccountName: scout
  automountServiceAccountToken: false
  containers:
    - name: client
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      resources:
        requests:
          memory: 2Gi
        limits:
          memory: 2Gi
```

Send it as a server-side dry run, so nothing is created:

```sh
kubectl apply --dry-run=server -f pod-too-big.yaml
```

The command fails with a `Forbidden` error that contains `exceeded quota: starfleet-quota`. Submit once more without `--keep` to grade the final state and remove the lab:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-02/labs/lab-01
```

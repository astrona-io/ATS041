# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01
```

`astrona submit` right after the start shows that every check fails, because no Pod Security label exists, `intruder` is running and `probe` uses a missing image tag.

## Step 1: Add the preventive control

The label `pod-security.kubernetes.io/enforce` makes the API server reject pods that violate the named level when they are created. Add it for `baseline`:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline
```

The command prints `namespace/outpost labeled`. It may also print a warning that `intruder` would violate the level. The warning does not remove the pod. Check the rejection without creating anything:

```sh
kubectl run grader-test -n outpost --image=curlimages/curl:8.22.0 --dry-run=server --overrides='{"spec":{"containers":[{"name":"grader-test","image":"curlimages/curl:8.22.0","securityContext":{"privileged":true}}]}}' -- sleep 30
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01 --keep
```

The first command fails with an error that names PodSecurity and the privileged setting.

## Step 2: Add the detective controls

The labels `audit` and `warn` do not block anything. `audit` adds an annotation to the API server audit event, and `warn` sends a warning to the client. Add both at the `restricted` level:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/audit=restricted pod-security.kubernetes.io/warn=restricted
```

Check all three labels:

```sh
kubectl get namespace outpost --show-labels
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01 --keep
```

## Step 3: Remove the unmanaged pod

Pod Security Admission checks pods only when they are created or updated, so it does not remove `intruder`. Delete the pod. No controller recreates it, because no Deployment manages it:

```sh
kubectl -n outpost delete pod intruder
kubectl -n outpost get pods
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01 --keep
```

The second command lists only the `drifter` pod.

## Step 4: Roll back probe

A Deployment keeps its earlier ReplicaSets. `kubectl rollout undo` makes the Deployment use the template of the previous revision again:

```sh
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe
```

The first command prints `deployment.apps/probe rolled back`. Check the image and submit:

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-02/labs/lab-01
```

The first command prints `mccutchen/go-httpbin:2.25.0`. The last submit grades the final state and removes the lab.

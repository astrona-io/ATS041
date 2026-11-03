# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Remove anonymous access

Ask the API server what an unauthenticated caller may do. The flags `--as` and `--as-group` impersonate the anonymous user and its group:

```sh
kubectl auth can-i list pods -n starfleet --as=system:anonymous --as-group=system:unauthenticated
```

The answer is `yes`. Find the bindings that name the group:

```sh
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[]? | .name == "system:unauthenticated") | .metadata.name + " -> " + .roleRef.name'
```

Two bindings are listed. `system:public-info-viewer` is built in and grants only a few public paths. `public-view` grants the `view` ClusterRole. Delete only that one:

```sh
kubectl delete clusterrolebinding public-view
```

The command prints `clusterrolebinding.rbac.authorization.k8s.io "public-view" deleted`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01 --keep
```

The check `anonymous-access-removed` now passes.

## Step 2: Remove the host path and enforce baseline

Test the level first with a server-side dry run. It changes nothing:

```sh
kubectl label --dry-run=server --overwrite namespace starfleet pod-security.kubernetes.io/enforce=baseline
```

The command prints a warning that existing pods violate the level, and it names the `node-inspector` pod. Delete its Deployment and enforce the level:

```sh
kubectl -n starfleet delete deployment node-inspector
kubectl label --overwrite namespace starfleet pod-security.kubernetes.io/enforce=baseline
```

The first command prints that the Deployment was deleted, and the second prints `namespace/starfleet labeled`. Prove that a host path pod is refused. Save this as `pod-hostpath-test.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-test
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      volumeMounts:
        - name: node-etc
          mountPath: /node-etc
  volumes:
    - name: node-etc
      hostPath:
        path: /etc/kubernetes
```

Send it as a dry run, so nothing is created:

```sh
kubectl apply --dry-run=server -f pod-hostpath-test.yaml
```

The API server answers with a Forbidden error whose text says that the pod violates PodSecurity `baseline` and names the host path volume. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01 --keep
```

The checks `node-inspector-removed` and `baseline-enforced` now pass.

## Step 3: Narrow the scout permissions

Save this as `role-scout-config.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: scout-config-reader
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["fleet-settings"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: scout-config-reader
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: scout
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: scout-config-reader
```

Apply it and remove the binding that grants the Secret access:

```sh
kubectl apply -f role-scout-config.yaml
kubectl -n starfleet delete rolebinding scout-secrets
```

Check the two answers that matter:

```sh
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout
kubectl auth can-i get configmaps/fleet-settings -n starfleet --as=system:serviceaccount:starfleet:scout
```

The first answer is `no` and the second is `yes`. Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/labs/lab-01
```

All five checks must pass. Then remove the lab:

```sh
astrona destroy ats-041-lab-020-02
```

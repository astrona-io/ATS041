# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01
```

Right after the start, `astrona submit` shows several failing checks. Only `scout-available` passes, because the privileged `scout` is running.

## Step 1: Remove the cluster-admin grant from shuttle

Find the binding that names `shuttle`:

```sh
kubectl get clusterrolebindings -o wide | grep shuttle
```

The ClusterRoleBinding is called `shuttle-admin`. Delete it. This removes the grant and keeps the service account:

```sh
kubectl delete clusterrolebinding shuttle-admin
```

The command prints `clusterrolebinding.rbac.authorization.k8s.io "shuttle-admin" deleted`. Check the result. The first command prints `no`:

```sh
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01 --keep
```

## Step 2: Stop mounting the token in shuttle

The field `automountServiceAccountToken` in the pod template decides whether the API server adds the token volume to the pod. Set it to `false` with a patch:

```sh
kubectl -n starfleet patch deployment shuttle -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n starfleet rollout status deployment/shuttle
```

The first command prints `deployment.apps/shuttle patched`. Check that the new pod has no volume whose name starts with `kube-api-access`:

```sh
kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[*].spec.volumes[*].name}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01 --keep
```

The first command prints nothing when the pod has no volumes.

## Step 3: Harden the scout container

Save this as `scout-hardened.yaml`. It is the full `scout` Deployment without `privileged`, without the `hostPath` volume, and with the three container settings. The pod-level `runAsNonRoot` and `runAsUser` apply to every container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
  labels:
    app: scout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      serviceAccountName: scout
      securityContext:
        runAsNonRoot: true
        runAsUser: 100
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              memory: 64Mi
```

Apply it:

```sh
kubectl apply -f scout-hardened.yaml
```

The command prints `deployment.apps/scout configured`. Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.volumes}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01 --keep
```

The second command prints nothing, because the pod template has no volumes any more.

## Step 4: Confirm everything and finish

Submit once more without `--keep` to grade the final state and remove the lab:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/module-01/labs/lab-01
```

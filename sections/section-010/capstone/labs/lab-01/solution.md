# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01
```

Right after the start, `astrona submit` shows that every check fails. Treat every failure as expected at this point.

## Step 1: Remove the cluster-admin grant

List the bindings that mention `beacon`, then delete the one that gives `cluster-admin`:

```sh
kubectl get clusterrolebindings -o wide | grep beacon
kubectl delete clusterrolebinding beacon-admin
kubectl auth can-i list secrets -n relay --as=system:serviceaccount:relay:beacon
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01 --keep
```

The `can-i` command prints `no`.

## Step 2: Remove the stray pod

Pod Security Admission never removes running pods, so delete the unmanaged pod yourself. No controller recreates it:

```sh
kubectl -n relay delete pod stray
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01 --keep
```

## Step 3: Harden beacon and enforce restricted

Save this as `beacon-restricted.yaml`. It is the full `beacon` Deployment with the restricted settings, no host path and no token:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: beacon
  namespace: relay
  labels:
    app: beacon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: beacon
  template:
    metadata:
      labels:
        app: beacon
    spec:
      serviceAccountName: beacon
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 100
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: beacon
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

Apply it and wait for the rollout:

```sh
kubectl apply -f beacon-restricted.yaml
kubectl -n relay rollout status deployment/beacon
```

Then enforce the level. Doing this after the fix means the new pod is already admitted. Add `audit` and `warn` too, so violations stay visible:

```sh
kubectl label namespace relay pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/audit=restricted pod-security.kubernetes.io/warn=restricted
kubectl -n relay get pods
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-010/capstone/labs/lab-01
```

The pod list shows one `beacon` pod. The last submit grades the final state and removes the lab.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01
```

Right after the start, `astrona submit` shows failing checks. Only the check for the other workloads passes if the `ledger` pod is running.

## Step 1: Read the password and create the Secret

The password is a literal value in the pod template. Read it:

```sh
kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[0].env}'
```

The command prints the variable `DB_PASSWORD` with the value `ledger-pass-7`. Save this as `secret-ledger-db.yaml`. The field `stringData` takes the plain value, and the API server stores it encoded in `data`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ledger-db
  namespace: starfleet
type: Opaque
stringData:
  password: ledger-pass-7
```

Apply it:

```sh
kubectl apply -f secret-ledger-db.yaml
```

Then check the result. The command prints the value that the Secret stores, decoded:

```sh
kubectl -n starfleet get secret ledger-db -o jsonpath='{.data.password}' | base64 -d
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01 --keep
```

The check `secret-holds-the-password` now passes.

## Step 2: Mount the Secret and remove the literal value

Save this as `deployment-ledger.yaml`. It is the full `ledger` Deployment without the `env` field, with a `db-credentials` volume from the Secret and a read-only mount at `/etc/ledger-db`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: starfleet
  labels:
    app: ledger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      serviceAccountName: ledger
      automountServiceAccountToken: false
      containers:
        - name: ledger
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          volumeMounts:
            - name: db-credentials
              mountPath: /etc/ledger-db
              readOnly: true
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              memory: 32Mi
      volumes:
        - name: db-credentials
          secret:
            secretName: ledger-db
```

Apply it:

```sh
kubectl apply -f deployment-ledger.yaml
```

The command prints `deployment.apps/ledger configured`. Then check the result. Wait for the rollout and read the pod template again. The second command prints nothing for the environment:

```sh
kubectl -n starfleet rollout status deployment/ledger
kubectl -n starfleet get deployment ledger -o jsonpath='{.spec.template.spec.containers[0].env}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01 --keep
```

The checks `no-plaintext-credential`, `secret-mounted-read-only` and `ledger-available` now pass.

## Step 3: Remove the Secret access of shuttle

Find the binding that names `shuttle`:

```sh
kubectl -n starfleet get rolebindings -o wide
```

The RoleBinding `shuttle-secret-reader` gives the Role `secret-reader` to `shuttle`. Delete the binding. This removes the grant and keeps the service account:

```sh
kubectl -n starfleet delete rolebinding shuttle-secret-reader
```

The command prints `rolebinding.rbac.authorization.k8s.io "shuttle-secret-reader" deleted`. Check the result. The command prints `no`:

```sh
kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01 --keep
```

## Step 4: Confirm everything and finish

Submit once more without `--keep` to grade the final state and remove the lab:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/module-01/labs/lab-01
```

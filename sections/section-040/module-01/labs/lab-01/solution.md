# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Read what the Deployment grants

Print the pod template of `relay` and read the fields that give access to the node:

```sh
kubectl -n outpost get deployment relay -o json | jq '.spec.template.spec | {hostPID, hostNetwork, hostIPC, serviceAccountName, automountServiceAccountToken, volumes, containers: [.containers[] | {name, securityContext, volumeMounts}]}'
```

The output lists `hostPID`, `hostNetwork` and `hostIPC` as `true`, a privileged container, a `hostPath` volume called `host-logs` and no setting for the token. The `relay` container only runs `sleep` and `curl`, so none of this is needed.

## Step 2: Apply the hardened Deployment

A pod field cannot be changed on a running pod, so you change the Deployment. The Deployment controller then replaces the pod. Save this as `relay-hardened.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
  labels:
    app: relay
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      serviceAccountName: relay
      automountServiceAccountToken: false
      hostPID: false
      hostNetwork: false
      hostIPC: false
      containers:
        - name: relay
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          securityContext:
            privileged: false
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              memory: 32Mi
```

Apply it:

```sh
kubectl apply -f relay-hardened.yaml
```

The command prints `deployment.apps/relay configured`. The volume and the volume mount are gone because the file does not contain them, and `kubectl apply` removes fields that it applied before and that are no longer in the file.

## Step 3: Wait for the rollout and check the running pod

```sh
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl -n outpost get pods -l app=relay -o json | jq '.items[] | {name: .metadata.name, hostPID: .spec.hostPID, hostNetwork: .spec.hostNetwork, privileged: .spec.containers[0].securityContext.privileged}'
```

The rollout command ends when the new pod is ready. The `jq` command prints `false` for each field. If an old pod is still shown with `true`, it is terminating; run the command again.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-01/labs/lab-01 --keep
```

All five checks pass. If `relay-running-hardened` fails, the rollout has not finished or the pod template lost its label, image or read-only root filesystem.

## Wrong fixes the checks reject

- Setting `privileged: false` but leaving `hostPID: true`: `host-namespaces-off` fails.
- Dropping `ALL` capabilities and then adding `SYS_ADMIN` back: `container-not-privileged` fails.
- Removing only the `volumeMounts` entry: `no-host-path` fails, because the volume is still in the pod template.
- Setting the token field only on a different service account: `token-not-mounted` fails, because the check reads the pod template and the `relay` service account.
- Deleting the Deployment and creating a Deployment with another name or image: `relay-running-hardened` fails.

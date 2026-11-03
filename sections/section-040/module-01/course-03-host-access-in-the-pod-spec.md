---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Host Access In The Pod Spec

A container is isolated because the container runtime starts it inside new Linux namespaces and a control group. The pod spec, which is the YAML a developer writes, can switch most of that isolation off with a single line. A pod with `hostPID: true` is no longer in its own process list, and a pod with `privileged: true` is barely restricted at all. This part names the fields that connect a container to the node, shows what each one exposes, and shows the settings that tighten a container again.

## Fields that remove isolation

Each field below gives the container something that belongs to the node. A reviewer who reads a pod spec for security looks for these first.

- `hostPID: true` puts the pod in the PID namespace of the node. Its processes see every process on the node, including the kubelet and the container runtime. With enough rights, a process can read their environment or send them signals.
- `hostNetwork: true` puts the pod in the network namespace of the node. The pod uses the IP address of the node, can listen on node ports and can reach services that listen only on the loopback interface of the node. A `NetworkPolicy` does not apply to such a pod in the usual way, because its traffic is not traffic from a pod network address.
- `hostIPC: true` shares the inter-process communication namespace of the node, including its shared memory.
- `privileged: true` in the container `securityContext` gives the container nearly all capabilities and access to the devices of the node. It is close to running the program directly on the node as root.
- A `hostPath` volume mounts a file or directory of the node into the container. A mount of `/var/run` or `/` can expose the socket of the container runtime or the whole file system of the node.
- `capabilities.add` gives specific extra Linux capabilities, for example `SYS_ADMIN` or `NET_ADMIN`. Each one widens what root inside the container can do to the kernel.
- `allowPrivilegeEscalation: true`, which is the default, lets a process gain more privileges than its parent through programs such as `sudo` or set-user-ID binaries.

A debugging tool for nodes needs several of these fields. A client that only sends HTTP requests needs none of them. The rule is to grant a pod only the fields that its job needs.

## See what host access looks like

The playground has the `relay` Deployment in `outpost`. It runs with `hostPID: true` and nothing else. Run `ps` inside it:

<!-- astrona:playground:renew -->

```sh
kubectl exec deploy/relay -n outpost -- ps
```

Compare the result with the `ps` output of `shuttle`, which has a few processes. The list from `relay` is long. It contains the kubelet, the container runtime, the processes of other pods and system services of the node. One field of the pod spec removed the process separation. Now read the spec itself, as a reviewer would:

```sh
kubectl get pod -n outpost -l app=relay -o json | jq '.items[0].spec | {hostPID, hostNetwork, hostIPC, automountServiceAccountToken, volumes: [.volumes[]?.name], containers: [.containers[] | {name, securityContext}]}'
```

A field that the pod does not set is printed as `null`. The pod has `hostPID` set to `true`, and no `securityContext` on the container. Without a `securityContext`, the container runs with the defaults of the container runtime, and `allowPrivilegeEscalation` defaults to true. The `volumes` list shows the projected volume that carries the service account token, because the token mount is on by default.

## Settings that tighten a container

The fields that reduce the access of a container are all in `securityContext`, either on the pod or on one container:

| Field | What it does |
| --- | --- |
| `allowPrivilegeEscalation: false` | The process cannot gain more privileges than it starts with |
| `capabilities.drop: ["ALL"]` | Removes every Linux capability from the container |
| `readOnlyRootFilesystem: true` | The container cannot write to its own root file system |
| `runAsNonRoot: true` | The kubelet refuses to start the container if it would run as user 0 |
| `seccompProfile.type: RuntimeDefault` | Applies the default system-call filter of the runtime |

On the pod level, `automountServiceAccountToken: false` stops the token mount. Together, these settings are the pattern of the Pod Security Standards level `restricted`, which Kubernetes defines as the hardened profile. A read-only root file system is not part of that standard, but it stops an attacker from writing tools or scripts into the container.

Save this as `pod-sealed-client.yaml`. It is a client pod that sends HTTP requests and holds none of the access above:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sealed-client
  namespace: outpost
  labels:
    app: sealed-client
spec:
  serviceAccountName: relay
  automountServiceAccountToken: false
  containers:
    - name: client
      image: curlimages/curl:8.22.0
      command: ["sh", "-c", "while true; do sleep 30; done"]
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
        seccompProfile:
          type: RuntimeDefault
      resources:
        requests:
          cpu: 10m
          memory: 16Mi
        limits:
          memory: 32Mi
```

Apply it:

```sh
kubectl apply -f pod-sealed-client.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Ready pod/sealed-client -n outpost --timeout=120s
kubectl exec sealed-client -n outpost -- ls /var/run/secrets/kubernetes.io/serviceaccount
kubectl exec sealed-client -n outpost -- touch /tmp/test-file
```

The `ls` command fails because the directory does not exist: no token was mounted. The `touch` command fails with a read-only file system error, because the root file system is read-only. The pod still runs its main process, and `curl` still works. The tightening removed rights the client never used.

## Where the controls are enforced

These fields are only requests in a pod spec. The kubelet and the container runtime enforce them on the node. Nothing stops a developer from writing `privileged: true` unless an admission control checks the spec before the pod is stored. Pod Security Admission is the built-in admission controller for this. It reads the label `pod-security.kubernetes.io/enforce` on a namespace and rejects pods that break the chosen level. A policy engine such as a validating admission policy can add custom rules. Both work at creation time and do not change pods that already run.

This closes the picture of one node. A container is a restricted process, the pod spec can widen or narrow the restrictions, and an admission control decides which pod specs may enter the cluster. What each control costs and where a boundary needs more than a pod field is a design question for the next level.

## Common pitfalls

> [!WARNING]
> Setting `privileged: false` does not remove `hostPID`, `hostNetwork` or `hostPath`. Dropping `ALL` capabilities and then adding one back, such as `SYS_ADMIN`, restores a large part of the access. Removing only the `volumeMount` leaves the `hostPath` volume in the pod spec. Changing a pod spec in a running Deployment replaces the pods; it does not change the old ones in place.

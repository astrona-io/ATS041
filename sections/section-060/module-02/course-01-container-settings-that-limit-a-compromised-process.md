---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Container Settings That Limit A Compromised Process

A flaw in the code of `scout` lets an attacker run commands inside the container. The attacker now holds a process with the rights that the pod gave it. If the process is root, can write anywhere, keeps every Linux capability and may gain more privileges, the attacker can install tools, change files and attack the node. If the pod removed those rights in advance, the same flaw gives the attacker much less. This part explains each setting, shows how to check it inside a running container, and applies the settings to a Deployment.

## A container is a process with limits

A container is a normal Linux process that the kernel limits. Kubernetes passes the limits that the pod asks for to the container runtime, and the runtime sets them before it starts the process. The kernel then enforces them. This means a setting in the pod spec changes real kernel behaviour for that process, and you can read the result from inside the container.

The settings in this part live in the `securityContext` field. It exists at pod level, where it applies to all containers, and at container level, where the container value wins when both are set.

## Run as a non-root user

Every Linux process has a user ID. User ID 0 is root, and root can change almost every file and, with the right capabilities, almost every kernel setting. The field `runAsNonRoot: true` tells the kubelet to refuse to start a container whose user is root. The field `runAsUser` sets the user ID directly.

The kubelet can verify `runAsNonRoot` only when it sees a numeric user ID. An image that names its user (for example `USER app`) with no `runAsUser` in the pod fails with a configuration error. The usual fix is to set a numeric `runAsUser` that is not 0.

A process that is not root cannot write to most system directories, cannot bind ports below 1024 without a capability, and cannot read files that belong to other users and have no read permission for others.

## Linux capabilities

Linux splits the powers of root into capabilities. Examples are `NET_ADMIN` (change network settings), `SYS_ADMIN` (a large group of administration tasks), `CHOWN` (change file owners) and `NET_RAW` (open raw sockets, which allows packet forging). A container receives a default set from the runtime, even when it is not privileged.

The field `capabilities.drop` removes capabilities from the container, and `drop: ["ALL"]` removes every one. The field `capabilities.add` gives back only what the application needs, for example `NET_BIND_SERVICE` to listen on port 80. Dropping all and adding only the needed ones is the least-privilege pattern.

A non-root process in a container has an empty effective capability set unless something grants it capabilities. The drop is still valuable, because it removes capabilities from the bounding set, which limits what a child process can ever get.

## Privilege escalation

A setuid program is an executable that runs with the rights of its owner, usually root, whatever user starts it. An attacker who has a non-root shell can look for such a program to become root. The kernel flag `no_new_privs` makes this impossible: a process with the flag cannot gain more privileges through setuid programs or file capabilities.

The field `allowPrivilegeEscalation: false` sets this flag on the container process. The default is `true`. The field is also forced to `true` when the container is privileged or has the capability `CAP_SYS_ADMIN`, so you cannot combine them.

A privileged container (`privileged: true`) is a different class of risk. It receives almost all capabilities and access to host devices. Such a container is close to a root process on the node, and a good practice is never to run one in an application namespace.

## A read-only root file system

The field `readOnlyRootFilesystem: true` mounts the container's root file system read only. The application can still write to volumes that you mount, for example an `emptyDir` volume at `/tmp`. A compromised process cannot replace the application binary, drop a new tool, edit a configuration file or write a script to run later.

Many applications write temporary files and fail on a read-only root. The answer is a small writable volume at exactly the path that the application needs, not a writable root.

## System call filtering with seccomp

Secure Computing Mode (seccomp) lets the kernel filter the system calls that a process may make. A system call is a request from a process to the kernel, for example to open a file or to start a program. The `RuntimeDefault` profile is the default filter of the container runtime. It blocks a list of calls that ordinary applications do not need and that have been used in kernel exploits. Set it with `seccompProfile.type: RuntimeDefault`.

Without a profile, the container may run with no filter at all (`Unconfined`), unless the kubelet is configured to apply the default to every pod.

## See the settings inside two pods

The playground has two Deployments that run the same curl image. `loose-agent` runs as root with no settings. `tight-agent` uses every setting above. Start with the user:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/loose-agent -- id
kubectl -n starfleet exec deploy/tight-agent -- id
```

The first command prints a user ID of `0`. The second prints a user ID of `100`. Now read the kernel's view of the process. The file `/proc/self/status` holds the capability sets, the `no_new_privs` flag and the seccomp mode of the process that reads it:

```sh
kubectl -n starfleet exec deploy/loose-agent -- grep -E 'CapEff|NoNewPrivs|Seccomp:' /proc/self/status
kubectl -n starfleet exec deploy/tight-agent -- grep -E 'CapEff|NoNewPrivs|Seccomp:' /proc/self/status
```

For `tight-agent` the effective capability set `CapEff` is all zeros, `NoNewPrivs` is `1` and `Seccomp` is `2`, which means a filter is active. For `loose-agent`, `CapEff` is not zero and `NoNewPrivs` is `0`. A default kind cluster does not apply a default seccomp profile, so `Seccomp` is `0` there.

Try to write a file in `/tmp` in both containers:

```sh
kubectl -n starfleet exec deploy/loose-agent -- sh -c 'echo test > /tmp/marker && echo written'
kubectl -n starfleet exec deploy/tight-agent -- sh -c 'echo test > /tmp/marker && echo written'
```

The first command prints `written`. The second fails with an error about a read-only file system and does not print `written`.

## Apply the settings to a Deployment

Harden `loose-agent` with all settings and a writable `/tmp` volume. Save this as `deployment-loose-agent.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loose-agent
  namespace: starfleet
  labels:
    app: loose-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: loose-agent
  template:
    metadata:
      labels:
        app: loose-agent
    spec:
      serviceAccountName: loose-agent
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 100
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: loose-agent
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            - name: scratch
              mountPath: /tmp
      volumes:
        - name: scratch
          emptyDir: {}
```

Apply it:

```sh
kubectl apply -f deployment-loose-agent.yaml
```

Then check the result. Wait for the rollout and write to the two paths:

```sh
kubectl -n starfleet rollout status deployment/loose-agent
kubectl -n starfleet exec deploy/loose-agent -- sh -c 'echo test > /tmp/marker && echo written'
kubectl -n starfleet exec deploy/loose-agent -- sh -c 'echo test > /etc/marker && echo written'
```

The write to `/tmp` prints `written`, because the `emptyDir` volume is writable. The write to `/etc` fails. The application keeps the scratch space it needs and nothing else.

The settings in this part do not stop the flaw. They shrink what the attacker can do after the flaw is used: no root, no capabilities, no new privileges, no writable program files and a smaller kernel surface. A compromised pod can still use all the memory and processor time it is allowed to take, which is the next question.

## Common pitfalls

> [!WARNING]
> - **Setting `runAsNonRoot` for an image with a named user.** The kubelet cannot check a name. Set a numeric `runAsUser`.
> - **Dropping capabilities and keeping `privileged: true`.** A privileged container ignores the point of the other settings.
> - **Making the whole root file system writable because one path needs it.** Mount a volume at that path.
> - **Assuming a seccomp profile is applied by default.** Set `RuntimeDefault` in the pod unless the cluster configures it for all pods.
> - **Reading a container-level field as pod-level.** The container value wins when both are set.

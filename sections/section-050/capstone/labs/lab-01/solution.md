# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written without running the lab, so the text does not show command output except where the Kubernetes behavior makes it certain.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/capstone/labs/lab-01
```

## Step 1: Pin cargo to the recorded digest

```sh
DIGEST=$(kubectl -n shipyard get configmap release-record -o jsonpath='{.data.cargo-digest}')
kubectl -n shipyard set image deployment/cargo "cargo=ghcr.io/stefanprodan/podinfo@${DIGEST}"
```

The second command prints `deployment.apps/cargo image updated`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/capstone/labs/lab-01 --keep
```

The check `cargo-pinned-to-recorded-digest` now passes.

## Step 2: Create the pull secret and give it to the service account

```sh
kubectl -n shipyard create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=cargo-puller \
  --docker-password=s3al-pull-4410
kubectl -n shipyard patch serviceaccount loader -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'
```

The commands print `secret/registry-creds created` and `serviceaccount/loader patched`. Grade it with the same `astrona submit ... --keep` command. The check `pull-credentials-through-serviceaccount` now passes.

## Step 3: Write the policy

The expression collects every image, including init container images, and requires the pattern `@sha256:` followed by 64 hexadecimal characters at the end of each one. The `matches` function in CEL uses the RE2 regular expression syntax.

Save this as `validatingadmissionpolicy-require-image-digest.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: require-image-digest
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: images
      expression: >-
        object.spec.containers.map(c, c.image) +
        (has(object.spec.initContainers) ? object.spec.initContainers.map(c, c.image) : [])
  validations:
    - expression: "variables.images.all(i, i.matches('@sha256:[0-9a-f]{64}$'))"
      message: "Every image must be referenced by digest (repository@sha256:...)."
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicy-require-image-digest.yaml
```

## Step 4: Bind it to shipyard only

Save this as `validatingadmissionpolicybinding-require-image-digest-shipyard.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: require-image-digest-shipyard
spec:
  policyName: require-image-digest
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: shipyard
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicybinding-require-image-digest-shipyard.yaml
```

Then check the result. The policy needs a few seconds before the API server enforces it, so repeat the first command if it is accepted at first:

```sh
kubectl -n shipyard run tag-check --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
kubectl -n outpost run tag-check --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
```

The first command fails with an error that contains `denied request`. The second command succeeds. Run the grader without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/capstone/labs/lab-01
```

All five checks pass. Finally remove the lab:

```sh
astrona destroy ats-041-capstone-050
```

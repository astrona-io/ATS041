---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Untrusted Input, Authorization And Injection

The `scout` application accepts a report identifier from a caller and returns a stored document. Kubernetes can start the pod, give it an identity and restrict its processes. It cannot know whether this caller owns this report. If the application code does not check, nothing else in the cluster will. This part explains which security decisions belong to the application code, and then shows with a running pod that the platform lets any input through.

## What the platform decides and what the code decides

The Kubernetes control plane decides things about objects: who may create a pod, which pods may run in a namespace, which pods may open a connection to which other pods. Each of these decisions uses fields that Kubernetes understands, such as a user name, a label or a port.

The application decides things about its own data and operations. A report identifier, a search string or an uploaded file means nothing to Kubernetes. Kubernetes sees bytes in a request and delivers them to the container. The Kubernetes documentation calls the layer that holds this logic the code layer of the 4Cs (cloud, cluster, container, code). Controls in the outer layers reduce the damage of a flaw in the code, but they never remove it.

The first consequence is that a hardened pod can still be vulnerable. A pod that runs as a non-root user with all Linux capabilities dropped can still return another user's report, if the code returns whatever identifier the caller sends.

## Untrusted input

Untrusted input is any data that a caller or an external system controls and that the application has not proven correct. Query strings, headers, request bodies, file names, uploaded files and values read from another service all count.

Input validation means the application checks the format, size and allowed values of the input before it uses it. There are two basic approaches. An allow list accepts only values that match a known good pattern, for example a report identifier made of exactly 12 digits. A deny list rejects known bad patterns, which fails as soon as an attacker finds a pattern that the list forgot. Security guidance prefers the allow list.

Validation also bounds the input. A request body of two gigabytes, a list of one million items or a string that makes a regular expression run for minutes can exhaust the process. Limits on size and on processing time belong in the code, next to the validation of the format.

## Injection

Injection happens when untrusted data changes the meaning of an operation that the application sends to an interpreter. The interpreter can be a database that reads Structured Query Language (SQL), a command shell, a template engine or a file path resolver. The classic example is a query built by joining strings: the caller sends `1' OR '1'='1` as the identifier and the database reads the quote as part of the query, not as data.

The defence is to keep instructions and data apart. A parameterized query sends the statement and the values in separate fields, so the database never parses the value as an instruction. For file paths, the code resolves the path and checks that it stays inside the allowed directory, which stops a caller from sending `../../etc/passwd`. Escaping and filtering help, but a separate channel for data is stronger.

Platform controls change what a successful injection can do. A pod with a read-only root file system and no capabilities limits the damage of a command injection. They do not make the vulnerable code correct.

## Authentication and authorization are different questions

Authentication proves who the caller is. Authorization decides what that caller may do with a specific object. A request can be perfectly authenticated and still unauthorized: user A is logged in and asks for the report of user B.

This failure has a name that the exam and the security community both use: broken access control, often at the object level. The identifier is valid, the caller is real, and the code returns the data. The fix is a rule in the code that relates the authenticated user, the requested operation and the target object, for example "return the report only when its owner is the caller's organization". The rule must exist on every path to the data, including background exports and alternate routes of the application programming interface (API).

Kubernetes has its own authorization, called Role-Based Access Control (RBAC), but it covers requests to the Kubernetes API. It does not cover requests that one application receives from its clients.

## See the platform pass input through

The `probe` workload runs go-httpbin, a small service that echoes every request it receives. It has no validation, which makes it a useful stand-in for application code that trusts its input. The `shuttle` pod is a client in the same namespace.

Send `probe` a value that looks like an injection and a path traversal. The `--data-urlencode` option encodes the value, and `-G` sends it as a query string:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -G --data-urlencode "report=../../etc/passwd' OR '1'='1" http://probe.starfleet.svc.cluster.local/anything
```

The response is a JSON document. Its `args` field holds the value exactly as sent, with the quote characters and the dots intact. Nothing between `shuttle` and `probe` removed or checked a character. The cluster network and the pod settings are not designed to inspect application data.

Now send the same request from the `drifter` pod, which lives in a different namespace:

```sh
kubectl -n outpost exec deploy/drifter -- curl -s -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc.cluster.local/anything
```

The command prints `200`. `probe` answered a caller that is outside its namespace and that did not authenticate. By default Kubernetes allows every pod to connect to every other pod, and `probe` has no authorization rule of its own. A network policy could stop this connection, but it would still decide only which pods may connect. It would not decide which report a connected caller may read.

Both calls show the same fact from two sides. The platform checks who may connect and which pod may run. The application must check what the caller sends and what the caller may read. If the code of `probe` were a real report service, the second call would have returned reports to an unknown caller. An application should therefore log the authenticated user and the object identifier of each request itself, because the cluster does not record them.

## Where to validate

A trust boundary is a place where data moves from a less trusted party to a more trusted one. The edge of the application is one. A call from another internal service is another, because that service may itself have been compromised or may pass on data from its own callers.

Validation in a browser or a mobile app only helps the honest user. An attacker sends requests directly, so the server must validate every value again. Each service that receives data validates it, even when the caller is inside the same cluster. This is also called defence in depth at the code layer: more than one check, so that a gap in one does not decide the outcome.

## Errors and logs are an output too

Every response and every log line is output of the application, and output can leak. An error page that prints a stack trace, a connection string or the text of a failed query helps an attacker as much as an operator. A log line that prints a full request can store a password or a token in a place with a much wider audience than the original secret.

The rule is to return the caller a short, useful error and to keep the detail in a log that only operators can read. Credentials, tokens and personal records are masked before they reach the log.

## Retries and repeated requests

A client that times out will usually send the request again. If the server had already committed the first request, the repeat creates a second report, a second payment or a second order. Safe repetition is a property of the application: an idempotency key sent by the client lets the server recognize that two requests are the same logical operation and return the first result. A proxy or a service mesh cannot know that contract from the method and the path.

This part followed one request from a client to the code. The platform delivers it, the code must validate it, authorize it and answer without leaking. A pod still needs a way to receive the credentials that the code uses to reach its own data. The question of how to deliver such a credential is the next topic.

## Common pitfalls

> [!WARNING]
> - **Treating a compliant pod as a secure application.** Pod hardening limits what a compromised process can do. It does not check inputs or ownership of data.
> - **Validating the format and skipping authorization.** A well-formed identifier can still belong to someone else.
> - **Building queries or commands from strings.** Use parameters and path checks so data cannot become instructions.
> - **Assuming the network decides who may read a record.** A network policy limits connections between pods. It does not know users or objects.
> - **Logging whole requests.** Headers and bodies often carry tokens and passwords.

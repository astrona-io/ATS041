# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCSA). Domain: Overview of Cloud Native Security (14%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-and-cloud-native-security-associate-kcsa/) on 2026-10-11. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | The 4Cs of Cloud Native Security | 1 | Written; review pending |
| 020 | Cloud Provider and Infrastructure Security | 1 | Written; review pending |
| 030 | Controls and Frameworks | 1 | Written; review pending |
| 040 | Isolation Techniques | 1 | Written; review pending |
| 050 | Artifact Repository and Image Security | 1 | Written; review pending |
| 060 | Workload and Application Code Security | 1 | Written; review pending |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | Security Across Cloud, Cluster, Container And Code | 1 | Identify the asset and responsibility at each of the four security layers.; Explain how failure in an outer layer can undermine inner controls.; Compare preventive, detective and corrective protections.; Apply defense in depth to an application scenario. |
| 020 / 01 | Cloud And Infrastructure Responsibilities | 1 | Explain shared responsibility for managed and self-managed infrastructure.; Identify powerful infrastructure identities and their workload impact.; Compare network exposure controls with application permissions.; Relate recovery and metadata access to infrastructure protection. |
| 030 / 01 | Controls, Risk And Frameworks | 1 | Distinguish a threat, vulnerability, risk and security control.; Compare preventive, detective and corrective control purposes.; Explain how a framework organizes controls and evidence.; Evaluate a control's implementation and residual risk. |
| 040 / 01 | Isolation And Containment Boundaries | 2 | Explain container and virtual-machine isolation boundaries.; Distinguish Linux namespaces from Kubernetes namespaces.; Relate process privileges and host access to containment.; Compare resource, network and identity segmentation. |
| 050 / 01 | Artifact And Image Assurance | 2 | Distinguish artifact identity, publisher trust and vulnerability evidence.; Explain credential exposure through image and repository workflows.; Relate verification results to the exact deployed digest.; Identify residual risk after a passed supply-chain check. |
| 060 / 01 | Application Code And Workload Protection | 1 | Identify input validation and application authorization responsibilities.; Explain dependency maintenance and sensitive-data handling.; Relate safe retries and resource use to application security.; Distinguish platform policy from business-level correctness. |

Every section begins with an introduction. Every module ends with a summary before the next module. YAML checkpoint banks follow selected section summaries; a domain review bank closes the course. They are indexed separately for future application integration.

Labs, playgrounds, capstones and per-section quiz.yaml files are now in scope (the maintainer lifted the reading-only limit on 2026-11-03); they are being added and are not yet listed in the manifest. Technical content remains draft until review; no runtime execution or lab validation is claimed.

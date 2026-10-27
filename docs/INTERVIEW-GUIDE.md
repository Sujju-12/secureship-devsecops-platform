# Interview guide

## 60-second explanation

SecureShip is a DevSecOps and software supply-chain security lab. I used a small Flask API so I could focus on the delivery lifecycle: automated tests, secret detection, dependency and container scanning, Terraform validation, SBOM generation, image signing and Kubernetes admission policies. CI creates a CycloneDX SBOM and scans the container; the release workflow publishes an immutable SHA-tagged image to GHCR and signs its digest using GitHub OIDC and Cosign. Kyverno policy examples demonstrate controls at deployment time. I designed it to run without a permanent AWS environment.

Only describe controls you have actually run and verified. Be clear about configured workflows versus successful workflow runs.

## Questions

### Why generate an SBOM?
It records the components in an artifact and supports inventory, vulnerability triage and incident response. It is not proof that the artifact is secure.

### Scanning versus signing?
Scanning searches for known vulnerabilities, secrets or misconfiguration. Signing associates an identity with an artifact digest and supports integrity/provenance checks. A signed image can still be vulnerable.

### Why sign a digest instead of a tag?
Tags can move; a digest identifies the exact image content. Verify the digest and expected signer identity at deployment.

### Why use OIDC for signing?
Keyless signing uses a short-lived workload identity and certificate rather than a long-lived private signing key stored as a CI secret. Verification must check the expected certificate identity and issuer.

### What does Kyverno do?
It evaluates admission requests against policies and can reject non-compliant workloads before they are accepted by the Kubernetes API server. Test policies against the exact Kyverno version; stage changes in Audit before Enforce.

### How do you handle false positives?
Review evidence, assess exploitability, upgrade or mitigate, and document narrowly scoped exceptions with an owner and expiry. Do not disable the whole security gate to get a green build.

### Production improvements?
Pin third-party actions to full commit SHAs, add provenance attestations, enforce branch protection and required checks, use isolated ephemeral runners, monitor exceptions, and test policy failure modes.

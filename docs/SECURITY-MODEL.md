# Security model

## Assets
- Source code and release artifacts
- CI identity and registry write permissions
- Container images and SBOMs
- Kubernetes workloads and deployment permissions
- Secrets used by optional integrations

## Threats and controls

| Threat | Control | Limitation |
|---|---|---|
| Secret committed to Git | Gitleaks workflow | Rotate any exposed secret; scanning does not revoke it. |
| Vulnerable package/image | Trivy scans | Databases change; review findings and exploitability. |
| Insecure IaC | Terraform validation and Checkov | Expand examples and test fixtures before production use. |
| Missing component inventory | Syft CycloneDX SBOM | An SBOM is an inventory, not a security verdict. |
| Image replaced after build | Cosign signature on digest | Verify both digest and expected signer identity. |
| Mutable image tag | Kyverno policy | Prefer digests for production releases. |
| Unsafe pod configuration | Restricted namespace and Kyverno policy | Test policies with the deployed Kyverno version. |
| Excessive CI permissions | Minimal workflow permissions | Audit every added action and permission. |

## Operating rules
1. Never commit real credentials.
2. Document scanner exceptions with owner, rationale and expiry.
3. Prefer immutable image digests.
4. Use short-lived workload identities where possible.
5. Do not grant CI or automation cluster-admin for convenience.
6. Test admission policies in a disposable cluster before enforcement.
7. A passing pipeline does not guarantee software security.

For demonstrations, use clearly fake test credentials only. If any real credential is exposed, revoke and rotate it immediately.

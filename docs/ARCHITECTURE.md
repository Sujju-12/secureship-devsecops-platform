# SecureShip architecture

SecureShip is a local-first DevSecOps and software supply-chain security lab. The application is intentionally small so the focus stays on delivery controls.

## Delivery flow

1. Pull requests run lint, tests, Gitleaks, Trivy filesystem/dependency scanning, Terraform validation and Checkov.
2. CI builds the container, scans it, generates a CycloneDX SBOM and uploads the SBOM as an artifact.
3. The release workflow builds an immutable SHA-tagged image and publishes it to GitHub Container Registry (GHCR).
4. Cosign signs the image digest using the GitHub Actions OIDC identity.
5. Kyverno policy examples show how to reject mutable tags and require non-root containers. A signature verification policy is supplied in Audit mode for controlled testing.

## Trust boundaries

- GitHub Actions runner: ephemeral build environment; grant only the permissions required by each workflow.
- Registry: stores artifacts; prefer immutable image references and verify signatures.
- Kubernetes API: admission policy is the enforcement point; a signature does not prove an image has no vulnerabilities.
- Human operator: triages findings and approves exceptions or production changes.

The default pipeline does not create AWS resources or require a permanently running Kubernetes cluster.

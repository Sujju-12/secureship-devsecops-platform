# SecureShip — DevSecOps & Software Supply Chain Security

SecureShip is a local-first portfolio lab showing how to add security controls across the software delivery lifecycle.

## Included controls

- Python Flask demo API with tests and a non-root Docker image
- GitHub Actions CI for tests, lint, Gitleaks secret detection, Trivy filesystem/container scans
- Terraform formatting/validation and Checkov IaC scanning
- Syft-generated CycloneDX SBOM artifacts
- Release workflow that publishes an immutable SHA-tagged image to GHCR and signs its digest with Cosign keyless OIDC
- Kubernetes restricted namespace, hardened workload manifest and Kyverno policy examples
- Threat model, local lab guide and interview walkthrough

> Learning/reference project. Workflow configuration is not proof that every check has passed. Review scan findings and validate the admission policies in a disposable cluster before using them in a shared environment.

## Quick start

Requirements: Python 3.12+; Docker is optional for API tests.

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r app/requirements-dev.txt
pytest -q
ruff check app
python app/app.py
```

Open `http://127.0.0.1:8080/healthz`.

## Build and inspect the image

```bash
docker build --pull -f app/Dockerfile -t secureship-demo:local .
trivy image --severity HIGH,CRITICAL --ignore-unfixed secureship-demo:local
syft secureship-demo:local -o cyclonedx-json=sbom.cdx.json
```

## Pipeline

```text
Pull request / push
  -> unit tests + lint
  -> Gitleaks secret scan
  -> Trivy filesystem/dependency/config scan
  -> Terraform validate + Checkov
  -> container build + Trivy image scan
  -> CycloneDX SBOM artifact
main branch release
  -> build and publish immutable SHA tag to GHCR
  -> Cosign keyless signature using GitHub OIDC
  -> release SBOM artifact
Kubernetes lab
  -> Kyverno policies for image tags and non-root execution
  -> optional example for signature verification (starts in Audit)
```

The default workflow does not provision AWS or require a permanently running Kubernetes cluster. Terraform is a validation exercise and creates no resources.

## Repository map

- `app/` — demo API, tests, dependencies and Dockerfile
- `.github/workflows/ci.yml` — pull request/push checks
- `.github/workflows/release.yml` — GHCR publication and image signing
- `terraform/` — optional Terraform validation and Checkov scan
- `k8s/` — namespace, deployment and Kyverno policies
- `scripts/local-check.sh` — local test/lint/scan helper
- `docs/` — architecture, threat model, local lab and interview notes
- `SECURITY.md` — project safety policy

## Important security principles

- Never commit real credentials; scanning does not revoke exposed secrets.
- Prefer immutable image digests and verify the expected signer identity.
- An SBOM is an inventory, not a guarantee that an image is safe.
- A signed image can still contain vulnerabilities.
- Test admission policies against the exact Kyverno version before enforcement.
- Review third-party GitHub Actions and pin them to full commit SHAs before treating the pipeline as production hardened.

See [Architecture](docs/ARCHITECTURE.md), [Security Model](docs/SECURITY-MODEL.md), [Local Lab](docs/LOCAL-LAB.md), and [Interview Guide](docs/INTERVIEW-GUIDE.md).

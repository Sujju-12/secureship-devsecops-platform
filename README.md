# SecureShip — DevSecOps & Software Supply Chain Security

SecureShip is a local-first portfolio lab that demonstrates how to add security controls across a software delivery pipeline.

## What it demonstrates

- Python Flask API with unit tests and a non-root container
- GitHub Actions CI: tests, Gitleaks secret scan, Trivy filesystem and image scans
- Terraform static validation and Checkov IaC scanning
- Syft SBOM generation (CycloneDX JSON)
- Cosign keyless image signing and verification for published images
- Kubernetes deployment baseline and Kyverno admission policies for security controls
- Documentation for threat model, local lab, release flow and interview walkthrough

> This is a learning/reference project. Security gates and policies must be tested in your environment before being treated as production controls. CI checks may fail when scanners identify vulnerabilities; review reports rather than blindly suppressing findings.

## Quick start

Requirements: Docker, Python 3.11+, Git, and optionally Kind, kubectl, Helm, Terraform, Trivy, Syft, Cosign and Kyverno.

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
python app/app.py
```

Open `http://127.0.0.1:8080/healthz`.

Build and scan the container:

```bash
docker build -t secureship-demo:local -f app/Dockerfile .
trivy image --severity HIGH,CRITICAL secureship-demo:local
syft secureship-demo:local -o cyclonedx-json=sbom.cdx.json
```

See [docs/LOCAL-LAB.md](docs/LOCAL-LAB.md) for the full workflow and [docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md) for security boundaries.

## Pipeline flow

```text
Pull request / push
  -> tests + lint
  -> secret scan + dependency/filesystem scan
  -> Terraform validation + Checkov
  -> container build + Trivy scan
  -> SBOM generation + artifact upload
  -> main branch: publish immutable image tag
  -> keyless sign image (OIDC identity)
  -> Kubernetes admission policy verifies image policy
```

The default workflow does not require AWS or a continuously running cluster. Registry publishing and cluster deployment are optional, explicitly configured extensions.

## Repository layout

- `app/` — Flask sample API, tests, requirements and Dockerfile
- `.github/workflows/` — CI and release workflow
- `terraform/` — minimal safe example and validation
- `k8s/` — namespace, deployment and Kyverno policies
- `scripts/` — local security checks and lab helpers
- `docs/` — architecture, local lab, threat model and interview notes

## Safety principles

- Never commit real credentials. Use Gitleaks to detect accidental exposure; rotate any credential that was exposed.
- Use least privilege and short-lived identities for CI where supported.
- Do not deploy mutable `latest` tags in production; prefer immutable digests.
- Treat scanner output as evidence to review, not proof of security.
- Keep remediation human-approved until controls are proven safe.

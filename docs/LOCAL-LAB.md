# Local lab

## Run tests

Python 3.12 is recommended.

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r app/requirements-dev.txt
pytest -q
ruff check app
```

## Run the API

```bash
python app/app.py
curl -fsS http://127.0.0.1:8080/healthz
curl -fsS http://127.0.0.1:8080/readyz
```

## Build, scan and generate an SBOM

```bash
docker build --pull -f app/Dockerfile -t secureship-demo:local .
trivy image --severity HIGH,CRITICAL --ignore-unfixed secureship-demo:local
syft secureship-demo:local -o cyclonedx-json=sbom.cdx.json
```

## Terraform checks

```bash
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
checkov -d terraform --framework terraform
```

This Terraform example declares a provider and output but creates no cloud resources. CI uses Checkov soft-fail initially so findings can be reviewed; tighten the gate after establishing a clean baseline.

## Kubernetes policies

Use a disposable Kind cluster and install Kyverno using the official instructions for the version you select. Apply the namespace, then the two baseline policies:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/kyverno/require-image-digest.yaml
kubectl apply -f k8s/kyverno/require-nonroot.yaml
```

Test compliant and non-compliant pods before using Enforce in a shared cluster. The signature verification policy is an example and starts in Audit mode.

## Image signature verification

The release workflow publishes a SHA-tagged image to GHCR and signs its digest using GitHub OIDC. After a successful release, verify the exact image tag:

```bash
cosign verify \\
  --certificate-identity "https://github.com/Sujju-12/secureship-devsecops-platform/.github/workflows/release.yml@refs/heads/main" \\
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \\
  ghcr.io/sujju-12/secureship-devsecops-platform:sha-<commit-sha>
```

Use the actual commit SHA. Authenticate if the GHCR package is private. Never bypass a failed signature check.

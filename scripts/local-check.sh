#!/usr/bin/env bash
set -euo pipefail

python -m pip install -r app/requirements-dev.txt
pytest -q
ruff check app

if command -v terraform >/dev/null 2>&1; then
  terraform -chdir=terraform fmt -check -recursive
  terraform -chdir=terraform init -backend=false
  terraform -chdir=terraform validate
else
  echo "Terraform not installed; skipping Terraform checks."
fi

if command -v docker >/dev/null 2>&1; then
  docker build -f app/Dockerfile -t secureship-demo:local .
  if command -v trivy >/dev/null 2>&1; then
    trivy image --severity HIGH,CRITICAL --ignore-unfixed secureship-demo:local
  else
    echo "Trivy not installed; image scan skipped."
  fi
else
  echo "Docker not installed; container checks skipped."
fi

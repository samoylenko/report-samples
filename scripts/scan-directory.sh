#!/usr/bin/env bash

set -e

mkdir -p "${REPORT_DIR}"

# Keeping metrics enabled to support the scanner teams.

# Grype
grype dir:. --output json --file "${REPORT_DIR}/grype-${REPORT_SUFFIX}".json
grype dir:. --output sarif --file "${REPORT_DIR}/grype-${REPORT_SUFFIX}".sarif

# Docker Scout
docker scout cves --format sarif --output "${REPORT_DIR}/scout-${REPORT_SUFFIX}.sarif" fs://. # SARIF ONLY

# Trivy
trivy filesystem . --format json --output "${REPORT_DIR}/trivy-${REPORT_SUFFIX}.json"
trivy filesystem . --format sarif --output "${REPORT_DIR}/trivy-${REPORT_SUFFIX}.sarif"

# Semgrep
semgrep --config=auto --secrets --dryrun --output="${REPORT_DIR}/semgrep-oss-${REPORT_SUFFIX}.json" --json
semgrep --config=auto --secrets --dryrun --output="${REPORT_DIR}/semgrep-oss-${REPORT_SUFFIX}.sarif" --sarif
semgrep ci --dry-run --code --secrets --supply-chain --output="${REPORT_DIR}/semgrep-pro-${REPORT_SUFFIX}.json" --json
semgrep ci --dry-run --code --secrets --supply-chain --output="${REPORT_DIR}/semgrep-pro-${REPORT_SUFFIX}.sarif" --sarif

# Snyk
snyk code test --all-projects --json-file-output="${REPORT_DIR}/snyk-code-${REPORT_SUFFIX}.json" --sarif-file-output="snyk-code-${REPORT_SUFFIX}.sarif"  || [ $? -le 2 ] # SARIF == JSON
snyk test --all-projects --json-file-output="${REPORT_DIR}/snyk-open-source-${REPORT_SUFFIX}.json" --sarif-file-output="snyk-open-source-${REPORT_SUFFIX}.sarif" || [ $? -le 2 ]

#!/usr/bin/env bash

set -e

: "${IMAGE:=$1}"
DIRNAME="${REPORT_DIR}/$(sed 's/:/\//g' <<< "${IMAGE}")"
mkdir -p "${DIRNAME}"
docker pull "${IMAGE}"
docker inspect "${IMAGE}" > "$DIRNAME/inspect.json"

# Keeping metrics enabled to support the scanner teams.
docker scout cves --format sarif --output "$DIRNAME/scout-${REPORT_SUFFIX}.sarif" "${IMAGE}"
grype "${IMAGE}" --output json --file "$DIRNAME/grype-${REPORT_SUFFIX}.json" >> grype.sh
grype "${IMAGE}" --output sarif --file "$DIRNAME/grype-${REPORT_SUFFIX}.sarif" >> grype.sh
snyk container test "${IMAGE}"  --sarif-file-output="$DIRNAME/snyk-${REPORT_SUFFIX}.sarif" --json-file-output="$DIRNAME/snyk-${REPORT_SUFFIX}.json" || [ $? -le 2 ]
syft "${IMAGE}" --output cyclonedx-json="$DIRNAME/syft-cyclonedx-${REPORT_SUFFIX}.json" --output spdx-json="$DIRNAME/syft-spdx-${REPORT_SUFFIX}.json"
trivy image "${IMAGE}" --format json --output "$DIRNAME/trivy-${REPORT_SUFFIX}.json"
trivy image "${IMAGE}" --format sarif --output "$DIRNAME/trivy-${REPORT_SUFFIX}.sarif"

## JFrog Xray - free trial expired, disabled, latest reports added manually
# jf docker scan "${IMAGE}" --format=json > "$DIRNAME/xray-${REPORT_SUFFIX}.json"
# sleep 10s
# jf docker scan "${IMAGE}" --format=sarif > "$DIRNAME/xray-${REPORT_SUFFIX}.sarif"

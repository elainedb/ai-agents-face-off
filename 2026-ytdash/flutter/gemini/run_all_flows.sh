#!/bin/bash
set -e
FLOWS=(
  "AC-LOGIN-01.yaml"
  "AC-LOGIN-02.yaml"
  "AC-LOGIN-03.yaml"
  "AC-LIST-01.yaml"
  "AC-LIST-02.yaml"
  "AC-LIST-03.yaml"
  "AC-COUNT-01.yaml"
  "AC-FILTER-01.yaml"
  "AC-SORT-01.yaml"
  "AC-LINK-01.yaml"
)
for flow in "${FLOWS[@]}"; do
  echo "Running $flow..."
  maestro --device 25251FDF60029V test \
    -e APP_ID=com.example.ytdash_flutter \
    -e MOCK_API_BASE=http://127.0.0.1:8090 \
    -e AUTHORIZED_EMAIL=user1@example.com \
    -e UNAUTHORIZED_EMAIL=deny@example.com \
    -e VIDEO_COUNT=8 \
    -e FILTER_LABEL="cronicas" \
    flows/$flow
done
echo "ALL FLOWS PASSED"

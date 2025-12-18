#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 DEPLOYMENT_NAME [OPTIONS]

Required:
  DEPLOYMENT_NAME           The Helm release name (used by kubectl diff)
  -f, --values FILE         Values file for the chart

Optional:
  -c, --chart-name NAME     Chart name (defaults to DEPLOYMENT_NAME)
  -r, --repo URL            Remote chart repository URL
  -v, --version VERSION     Remote chart version

  -h, --help                Show this help

Notes:
  - If CHART_NAME is not specified, it is set to DEPLOYMENT_NAME.
  - VALUES_FILE is mandatory.
  - OPTIONS env var is built from --repo / --version and appended to the Helm command.
EOF
  exit 1
}

# Need at least DEPLOYMENT_NAME
[[ $# -lt 1 ]] && usage

DEPLOYMENT_NAME="$1"
shift

CHART_NAME=""
VALUES_FILE=""
REMOTE_REPO=""
REMOTE_REPO_VERSION=""

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--chart-name)
      CHART_NAME="$2"
      shift 2
      ;;
    -f|--values)
      VALUES_FILE="$2"
      shift 2
      ;;
    -r|--repo)
      REMOTE_REPO="$2"
      shift 2
      ;;
    -v|--version)
      REMOTE_REPO_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Defaults
CHART_NAME="${CHART_NAME:-$DEPLOYMENT_NAME}"

# Validate required arguments
if [[ -z "$VALUES_FILE" ]]; then
  echo "Error: -f/--values is required."
  usage
fi

# Build OPTIONS env var from repo/version
OPTIONS=()
if [[ -n "$REMOTE_REPO" ]]; then
  OPTIONS+=(--repo "$REMOTE_REPO")
fi
if [[ -n "$REMOTE_REPO_VERSION" ]]; then
  OPTIONS+=(--version "$REMOTE_REPO_VERSION")
fi

# Local chart or remote chart
if [[ -n "$REMOTE_REPO" ]]; then
  # Remote: CHART is CHART_NAME
  CHART_PATH="$CHART_NAME"
else
  # Local: use current directory as chart
  CHART_PATH="."
fi

# Run helm template + kubectl diff
helm template \
  "$DEPLOYMENT_NAME" \
  "$CHART_PATH" \
  -f "$VALUES_FILE" \
  --no-hooks \
  "${OPTIONS[@]}" \
  | kubectl diff -f-


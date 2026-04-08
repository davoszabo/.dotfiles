#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 DEPLOYMENT_NAME [OPTIONS]

Required:
  DEPLOYMENT_NAME           The Helm release name (used by kubectl diff)
  -f, --values FILE         Values file for the chart

Optional:
  -c, --chart-name NAME     Chart name (defaults to DEPLOYMENT_NAME); used for classic
                            repos only, not for OCI (see below)
  -r, --repo URL            Classic Helm repo URL, or full OCI chart reference
                            (oci://registry/namespace/chart)
  -v, --version VERSION     Remote chart version
  -n, --namespace NAME      Kubernetes namespace for helm template and kubectl diff
                            (optional; omitted if not set)

  -h, --help                Show this help

Notes:
  - If CHART_NAME is not specified, it is set to DEPLOYMENT_NAME.
  - VALUES_FILE is mandatory.
  - Classic HTTP repos: pass -r with the index URL and -c with the chart name; Helm gets
    --repo and the chart name as the chart argument.
  - OCI registries: pass -r with the full oci://... chart reference (same form as
    helm install/pull). Do not use --repo; -c is ignored for the chart path.
  - --version is passed to helm template for both classic and OCI remotes.
  - With -n/--namespace, helm template gets --namespace and kubectl diff gets -n.
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
KUBE_NAMESPACE=""

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
    -n|--namespace)
      KUBE_NAMESPACE="$2"
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

# Build OPTIONS and chart path: classic repos use --repo + chart name; OCI uses the
# full oci:// reference as the chart argument (no --repo).
OPTIONS=()
if [[ -n "$REMOTE_REPO" ]]; then
  if [[ "$REMOTE_REPO" == oci://* ]]; then
    CHART_PATH="$REMOTE_REPO"
  else
    CHART_PATH="$CHART_NAME"
    OPTIONS+=(--repo "$REMOTE_REPO")
  fi
else
  CHART_PATH="."
fi
if [[ -n "$REMOTE_REPO_VERSION" ]]; then
  OPTIONS+=(--version "$REMOTE_REPO_VERSION")
fi

HELM_NAMESPACE_ARGS=()
KUBECTL_NAMESPACE_ARGS=()
if [[ -n "$KUBE_NAMESPACE" ]]; then
  HELM_NAMESPACE_ARGS+=(--namespace "$KUBE_NAMESPACE")
  KUBECTL_NAMESPACE_ARGS+=(-n "$KUBE_NAMESPACE")
fi

# Run helm template + kubectl diff
helm template \
  "$DEPLOYMENT_NAME" \
  "$CHART_PATH" \
  -f "$VALUES_FILE" \
  --no-hooks \
  "${HELM_NAMESPACE_ARGS[@]}" \
  "${OPTIONS[@]}" \
  | kubectl diff "${KUBECTL_NAMESPACE_ARGS[@]}" -f-


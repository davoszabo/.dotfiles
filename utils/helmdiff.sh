#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [OPTIONS] RELEASE_NAME [CHART]

Required:
  RELEASE_NAME              Helm release name (first positional argument)
  -f, --values FILE         Values file for the chart

Optional:
  CHART                     Helm-style chart argument (second positional argument):
                            - chart name (for classic repos)
                            - "." or local chart path
                            - full OCI reference (oci://registry/ns/chart)
  -c, --chart-name NAME     Legacy chart name fallback when CHART positional arg is omitted
  -r, --repo URL            Classic Helm repo URL, or full OCI chart reference
                            (oci://registry/namespace/chart) for backward compatibility
  -v, --version VERSION     Remote chart version
  -n, --namespace NAME      Kubernetes namespace for helm template and kubectl diff
                            (optional; omitted if not set)

  -h, --help                Show this help

Notes:
  - Preferred usage mirrors helm template:
      $0 [flags] RELEASE_NAME CHART -f values.yaml
  - If CHART is omitted, legacy fallback is used:
    - with --repo (classic): CHART is --chart-name or RELEASE_NAME
    - with --repo oci://... : CHART is that OCI reference
    - without --repo        : CHART defaults to "."
  - VALUES_FILE is mandatory.
  - For classic repos, --repo is only used as Helm's --repo URL.
  - For OCI charts, use CHART=oci://... (or legacy --repo oci://...).
  - --version is passed to helm template for classic and OCI charts.
  - With -n/--namespace, helm template gets --namespace and kubectl diff gets -n.
EOF
  exit 1
}

CHART_NAME=""
VALUES_FILE=""
REMOTE_REPO=""
REMOTE_REPO_VERSION=""
KUBE_NAMESPACE=""
POSITIONAL_ARGS=()

# Parse options and positional args in any order.
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
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL_ARGS+=("$1")
        shift
      done
      ;;
    *)
      if [[ "$1" == -* ]]; then
        echo "Unknown option: $1"
        usage
      fi
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Need at least RELEASE_NAME positional argument.
if [[ ${#POSITIONAL_ARGS[@]} -lt 1 ]]; then
  echo "Error: RELEASE_NAME is required."
  usage
fi
if [[ ${#POSITIONAL_ARGS[@]} -gt 2 ]]; then
  echo "Error: Too many positional arguments."
  usage
fi

DEPLOYMENT_NAME="${POSITIONAL_ARGS[0]}"
CHART_INPUT="${POSITIONAL_ARGS[1]:-}"

# Validate required arguments
if [[ -z "$VALUES_FILE" ]]; then
  echo "Error: -f/--values is required."
  usage
fi

# Build Helm options and chart path.
OPTIONS=()
if [[ -n "$CHART_INPUT" ]]; then
  CHART_PATH="$CHART_INPUT"
else
  if [[ -n "$REMOTE_REPO" ]]; then
    if [[ "$REMOTE_REPO" == oci://* ]]; then
      CHART_PATH="$REMOTE_REPO"
    else
      CHART_PATH="${CHART_NAME:-$DEPLOYMENT_NAME}"
      OPTIONS+=(--repo "$REMOTE_REPO")
    fi
  else
    CHART_PATH="."
  fi
fi

# For classic repos, a provided --repo remains valid even when CHART is positional.
if [[ -n "$CHART_INPUT" && -n "$REMOTE_REPO" && "$REMOTE_REPO" != oci://* ]]; then
  OPTIONS+=(--repo "$REMOTE_REPO")
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


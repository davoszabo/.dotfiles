#!/bin/bash

function usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "   -c,    --chart-name        The chart name"
    echo "   -f,    --values            Provide values file"
    echo
    echo "   -h,    --help              Show this help"
    exit 1
}

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
        -h|--help)
        usage
        ;;
        *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
done

# Validate required arguments
if [[ -z "$CHART_NAME" || -z "$VALUES_FILE" ]]; then
    usage
fi

helm template $CHART_NAME . -f $VALUES_FILE --no-hooks | kubectl diff -f-


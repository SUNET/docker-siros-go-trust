#!/bin/sh
set -e

CONFIG_FILE=${CONFIG_FILE:-/etc/go-trust/config.yaml}
PIPELINE_FILE=${PIPELINE_FILE:-/app/pipeline.yaml}

echo "Starting Go-Trust Service..."

if [ ! -f "${PIPELINE_FILE}" ]; then
    echo "Error: Pipeline file ${PIPELINE_FILE} not found"
    exit 1
fi

ARGS="--host 0.0.0.0"

if [ -f "${CONFIG_FILE}" ]; then
    ARGS="${ARGS} --config ${CONFIG_FILE}"
fi

ARGS="${ARGS} ${PIPELINE_FILE}"

echo "Starting gt with: ${ARGS}"
exec ./gt ${ARGS}

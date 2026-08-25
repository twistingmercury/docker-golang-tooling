#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
IS_LOCAL="${IS_LOCAL:-0}"
IMAGE_NAME=ghcr.io/twistingmercury/golang-tooling
GO_VERSION=$(shell go env GOVERSION)

cleanup_local_image() {
    local exit_status=$?

    if [[ "${IS_LOCAL}" == "1" ]]; then
        docker rmi "$(IMAGE_NAME):$(GO_VERSION)" -f || true
    fi

    exit "${exit_status}"
}

main(){
    trap cleanup_local_image EXIT

    docker build --no-cache --pull \
    --build-arg BUILD_DATE=$(BUILD_DATE) \
    --build-arg VCS_REF=$(VCS_REF) \
    --build-arg VERSION=$(GO_VERSION) \
    -t $(IMAGE_NAME):$(GO_VERSION) \
    -t $(IMAGE_NAME):latest .
}

main "$@"
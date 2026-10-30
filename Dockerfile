FROM golang:1.27.3-alpine3.24@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=latest

LABEL org.opencontainers.image.title="golang-tooling" \
    org.opencontainers.image.description="Alpine-based Go build image with security and linting toolchain" \
    org.opencontainers.image.source="https://github.com/twistingmercury/docker-golang-tooling" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Jeremy K. Johnson" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.base.name="golang:1.27.3-alpine3.24@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c"

RUN apk add --no-cache git ca-certificates bash gcc musl-dev \
    && apk add --no-cache shellcheck=0.11.0-r1 make=4.4.1-r4 \
    && go install github.com/swaggo/swag/cmd/swag@v1.16.6 \
    && go install github.com/securego/gosec/v2/cmd/gosec@71577268350e1e0f2f1491de1ef53f1227b43c1f \
    && go install golang.org/x/vuln/cmd/govulncheck@v1.9.0 \
    && go install golang.org/x/tools/cmd/goimports@v0.52.0 \
    && go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0 \
    && go install github.com/google/go-licenses/v2@v2.0.1 \
    && go clean -cache -modcache


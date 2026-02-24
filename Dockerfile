FROM golang:1.26-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=v1.26

LABEL org.opencontainers.image.title="golang-tooling" \
    org.opencontainers.image.description="Alpine-based Go build image with security and linting toolchain" \
    org.opencontainers.image.source="https://github.com/twistingmercury/docker-golang-tooling" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Jeremy K. Johnson" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.base.name="golang:1.26-alpine"

RUN apk add --no-cache git ca-certificates \
    && go install github.com/securego/gosec/v2/cmd/gosec@latest \
    && go install golang.org/x/vuln/cmd/govulncheck@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

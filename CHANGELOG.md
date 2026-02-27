# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Switched base image from pinned `golang:1.26-alpine` to rolling `golang:alpine`
- Updated build/tag defaults to publish `alpine` and `go{GO_VERSION}-alpine`
- `GO_VERSION` now derives from the local Go toolchain (`go env GOVERSION`) in the Makefile
- Added GitHub Actions workflow to build/push GHCR images and derive Go version from `golang:alpine`

## [1.0.0] - Unreleased

### Added

- Docker image extending golang:1.25-alpine with security and linting toolchain
- Pre-installed tools: gosec, govulncheck, goimports, golangci-lint
- Alpine packages: git, ca-certificates

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.27.1] - 2026-09-28

### Added

- Pre-installed tools: swag, shellcheck, make
- Alpine packages: bash, gcc, musl-dev

### Changed

- Switched base image from pinned `golang:1.26-alpine` to rolling `golang:alpine`
- Updated build/tag defaults to publish `latest` and `go{GO_VERSION}`
- `GO_VERSION` now derives from the local Go toolchain (`go env GOVERSION`) in the Makefile
- Added GitHub Actions workflow to build/push GHCR images and derive Go version from `golang:alpine`
- README recommends pinning to a `go{GO_VERSION}` tag instead of `latest`

### Fixed

- `build.sh` used Makefile `$(VAR)` syntax, left `BUILD_DATE`/`VCS_REF` unset, built from the caller's working directory, and left the `latest` tag behind on local cleanup
- README example ran `apk` in a `scratch` stage; it now copies CA certificates from the build stage and exposes `CGO_ENABLED` as a build argument

## [1.0.0] - Unreleased

### Added

- Docker image extending golang:1.25-alpine with security and linting toolchain
- Pre-installed tools: gosec, govulncheck, goimports, golangci-lint
- Alpine packages: git, ca-certificates

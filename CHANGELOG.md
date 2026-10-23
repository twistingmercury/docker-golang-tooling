# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Dependabot config for the base image and workflow actions (weekly, grouped)
- go-licenses v2.0.1, for checking dependency licenses against an allowed list and writing an attribution report

### Changed

- Base image is pinned to a version tag and digest (`golang:1.27.3-alpine3.24@sha256:...`) instead of rolling `golang:alpine`
- `build.sh` and the publish workflow read the Go version for tags from the Dockerfile `FROM` line instead of the host Go or the pulled base image
- `make build` now runs `build.sh` instead of calling `docker build` directly, so local builds set the OCI version, build date, and revision labels
- README restructured to follow the standard README template
- Go tools (swag, govulncheck, goimports, golangci-lint) are pinned to exact versions instead of `@latest`, so rebuilds are repeatable
- Image is much smaller: the Go build and module caches left by `go install` are now cleared in the same layer

## [1.27.2] - 2026-10-14

### Changed

- Pinned gosec version to `71577268350e1e0f2f1491de1ef53f1227b43c1f`

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

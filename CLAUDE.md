# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single Docker image, `ghcr.io/twistingmercury/golang-tooling`: `golang:alpine` plus Go build/lint/security tooling, meant to be used as the `build` stage of downstream multi-stage Dockerfiles. There's no Go source here; the product is the `Dockerfile`.

## Commands

```bash
make build   # docker build --no-cache --pull, tags :<GO_VERSION> and :latest
make push    # push both tags
make login   # needs GITHUB_GHRC_PAT in env
```

There are no tests. To verify a change, build and confirm the tools are there:

```bash
make build
docker run --rm ghcr.io/twistingmercury/golang-tooling:latest sh -c \
  'go version && gosec -version && govulncheck -version && golangci-lint version && goimports -h 2>&1 | head -1 && swag -v && shellcheck -V && make -v | head -1'
```

## How the image is built and tagged

- `Dockerfile` does everything in one `RUN`: `apk add` (git, ca-certificates, bash, gcc, musl-dev, plus pinned `shellcheck` and `make`), then `go install ...@latest` for swag, gosec, govulncheck, goimports, golangci-lint (v2 module path). Go tools float to latest; apk packages added in recent commits are pinned to exact Alpine revisions (`pkg=x.y.z-rN`), and those pins break when the `golang:alpine` base moves to a newer Alpine release.
- The base is rolling `golang:alpine`, so the Go version is whatever that tag resolves to at build time.
- **Version tagging differs between local and CI:**
  - `Makefile` sets `GO_VERSION` from the *host's* `go env GOVERSION` (e.g. `go1.27.0`) and passes it as both the tag and the `VERSION` build arg. If the host Go doesn't match the base image, the tag is wrong.
  - `.github/workflows/publish.yml` pulls `golang:alpine` and runs `go env GOVERSION` *inside it*: tag is `go1.27.0`, `VERSION` label is `1.27.0` (prefix stripped).
- CI publishes `:latest` and `:go<ver>` on every push to `develop` or `main` (and on `workflow_dispatch`). It needs the `GHCR_PAT` repo secret; see README "GHCR Troubleshooting" for PAT scopes and package access.
- OCI labels get their values from `BUILD_DATE`, `VCS_REF`, and `VERSION` build args.

## Keeping docs in sync

- When adding or removing a tool in the `Dockerfile`, update the tool list in `README.md` and the `[Unreleased]` section of `CHANGELOG.md` (Keep a Changelog format).

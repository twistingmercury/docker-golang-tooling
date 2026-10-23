# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single Docker image, `ghcr.io/twistingmercury/golang-tooling`: a pinned `golang:<go>-alpine<alpine>` base (version tag plus digest) plus Go build/lint/security tooling, meant to be used as the `build` stage of downstream multi-stage Dockerfiles. There's no Go source here; the product is the `Dockerfile`.

## Commands

```bash
make build   # runs ./build.sh: docker build --no-cache --pull, tags :<GO_VERSION> and :latest
make push    # push both tags
make login   # needs GITHUB_GHRC_PAT in env
```

There are no tests. To verify a change, build and confirm the tools are there:

```bash
make build
docker run --rm ghcr.io/twistingmercury/golang-tooling:latest sh -c \
  'go version && gosec -version && govulncheck -version && golangci-lint version && goimports -h 2>&1 | head -1 && swag -v && go version -m "$(command -v go-licenses)" | grep "mod.*go-licenses" && shellcheck -V && make -v | head -1'
```

## How the image is built and tagged

- `Dockerfile` does everything in one `RUN`: `apk add` (git, ca-certificates, bash, gcc, musl-dev, plus pinned `shellcheck` and `make`), then `go install` for swag, gosec, govulncheck, goimports, golangci-lint (v2 module path), go-licenses (v2 module path). Go tools are pinned to exact versions (gosec to a commit SHA), so a rebuild gives the same tools; apk packages added in recent commits are pinned to exact Alpine revisions (`pkg=x.y.z-rN`), and those pins break when the base moves to a newer Alpine release. Dependabot (`.github/dependabot.yml`) bumps the `FROM` tag and digest weekly but doesn't track the apk pins or the `go install` versions, so a base-bump PR can fail the build until they're refreshed.
- The base is pinned in the `FROM` line to a version tag plus the multi-arch index digest; the Go version is whatever that tag says.
- **Version tagging differs between local and CI:**
  - `make build` runs `build.sh`, which sets `GO_VERSION` from the Dockerfile's `FROM` line (e.g. `go1.27.3`) and passes it as both the tag and the `VERSION` build arg. `build.sh` also sets `BUILD_DATE` and `VCS_REF` (short HEAD SHA), and `IS_LOCAL=1` removes the local images when it exits.
  - `.github/workflows/publish.yml` reads the Go version from the Dockerfile's `FROM` line the same way: tag is `go1.27.3`, `VERSION` label is `1.27.3` (prefix stripped).
- CI publishes `:latest` and `:go<ver>` on every push to `develop` or `main` (and on `workflow_dispatch`). It needs the `GHCR_PAT` repo secret; see README "GHCR Troubleshooting" for PAT scopes and package access.
- OCI labels get their values from `BUILD_DATE`, `VCS_REF`, and `VERSION` build args.

## Keeping docs in sync

- When adding or removing a tool in the `Dockerfile`, update the tool list in `README.md` and the `[Unreleased]` section of `CHANGELOG.md` (Keep a Changelog format).

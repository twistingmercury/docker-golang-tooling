# golang-tooling

> **Maturity Level**: Basic - Go build image with security and linting tools.
>
> **Version**: v1.27.3
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare

---

It's `golang:alpine` with all the security and linting tools you'd normally
install yourself already baked in.

## Table of Contents

- [Usage](#usage)
- [How it works](#how-it-works)
- [Key Considerations](#key-considerations)
- [Development Considerations](#development-considerations)
- [Versioning](#versioning)

## Usage

Use it as the build stage of your own Dockerfile. Grab it from GitHub Container
Registry:

```bash
docker pull ghcr.io/twistingmercury/golang-tooling:go1.27.3
```

> I recommend not using `latest` for production builds. Pin the image to the
> Go version your app needs, and to its digest.

The [wiki](https://github.com/twistingmercury/docker-golang-tooling/wiki) is the
source of truth for how to use the image: a build stage and `build.sh` to start
from, what each tool does and the order to run them in, and examples for
building [packages](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-Packages),
[CLIs](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-CLIs),
and [services](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-Services).

## How it works

Instead of installing the same tools in every build, you get them all in one
base image: gosec, govulncheck, goimports, golangci-lint, swag, go-licenses,
shellcheck, and make, plus git, ca-certificates, bash, gcc, and musl-dev. The
[wiki](https://github.com/twistingmercury/docker-golang-tooling/wiki/The-Tools)
covers what each one is for.

## Key Considerations

- The base image and every tool are pinned to exact versions in the
  `Dockerfile`, so they only change when the `Dockerfile` does
- The image is about 1 GB, bigger than plain `golang:alpine` since all that
  tooling has to live somewhere
- Use a multi-stage build so none of it ends up in your final image

## Development Considerations

### Quick Start

Build it locally with the Makefile; `make build` runs `build.sh`, which tags
the image `go{GO_VERSION}` and `latest` and fills in the OCI labels:

```bash
make build
```

Set `IS_LOCAL=1` to have `build.sh` remove the local images when it finishes.
To publish, run `make login` (needs `GITHUB_GHRC_PAT` in your environment),
then `make push`.

### Testing

There are no automated tests. After a build, confirm the tools are in the image:

```bash
docker run --rm ghcr.io/twistingmercury/golang-tooling:latest sh -c \
  'go version && gosec -version && govulncheck -version && golangci-lint version && goimports -h 2>&1 | head -1 && swag -v && go version -m "$(command -v go-licenses)" | grep "mod.*go-licenses" && shellcheck -V && make -v | head -1'
```

### GHCR Troubleshooting

If GitHub Actions fails to push with `permission_denied: write_package`, check
these:

1. The `GHCR_PAT` repository secret is set.
2. It's a classic PAT with the `write:packages` and `read:packages` scopes.
3. It also has the `repo` scope if the repository is private.
4. In the package settings for `ghcr.io/twistingmercury/golang-tooling`, this
   repository has write/admin access under Actions access.
5. The repository's Actions workflow permissions are set to read and write.

## Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/).

Version is determined from git tags:

```bash
git describe --tags --always
```

The published image tags are:

- `latest` - the most recent build
- **(RECOMMENDED)** `go{GO_VERSION}` - the Go version of the pinned base image
  in the `Dockerfile` (for example, `go1.27.3`)

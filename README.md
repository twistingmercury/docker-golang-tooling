# golang-tooling

> **Maturity Level**: Emerging - Go build image with security and linting tools; the tool set may change between releases
> **Version**: v1.27.2
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare

---

It's `golang:alpine` with all the security and linting tools you'd normally
install yourself already baked in.

For how to use it and get the most out of it, see the
[wiki](https://github.com/twistingmercury/docker-golang-tooling/wiki).

## Table of Contents

- [Usage](#usage)
- [How it works](#how-it-works)
- [Key Considerations](#key-considerations)
- [Development Considerations](#development-considerations)
- [Versioning](#versioning)

## Usage

Grab it from GitHub Container Registry:

```bash
docker pull ghcr.io/twistingmercury/golang-tooling:latest
docker pull ghcr.io/twistingmercury/golang-tooling:go1.27.2
```

> I recommend not using `latest` for production builds. Pin the image to the
> Go version your app needs.

Then use it as the build stage in your Dockerfile:

```dockerfile
FROM ghcr.io/twistingmercury/golang-tooling:latest AS build
ARG CGO_ENABLED=0
WORKDIR /src
COPY . .
## Run linters, formatters, security scanners, etc
RUN goimports -w .
RUN golangci-lint run
RUN govulncheck ./...
RUN gosec ./...
RUN go test -v ./...
RUN go build -o /app/myapp .

FROM scratch AS runtime
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/myapp /usr/local/bin/
ENTRYPOINT ["myapp"]
```

A quick note on `CGO_ENABLED`: it's a build-stage arg, so it only changes how
`go build` links your binary. It doesn't touch the runtime image. Leave it at
`0` and you get a static binary that runs fine on `scratch`. If your app needs
cgo, pass `--build-arg CGO_ENABLED=1`, but then the binary needs musl at
runtime, so swap `scratch` for something that has it, like `alpine`.

The [wiki](https://github.com/twistingmercury/docker-golang-tooling/wiki) goes
further, with a build stage and `build.sh` to start from, what each tool does
and the order to run them in, and examples for building
[packages](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-Packages),
[CLIs](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-CLIs),
and [services](https://github.com/twistingmercury/docker-golang-tooling/wiki/Building-Services).

## How it works

Instead of installing the same tools in every build, you get them all in one
base image:

- **gosec** - finds security issues in Go code
- **govulncheck** - checks your dependencies for known vulnerabilities
- **goimports** - fixes up your imports
- **golangci-lint** - runs a whole pile of linters at once
- **swag** - generates Swagger docs for Go APIs
- **go-licenses** - checks your dependencies' licenses against an allowed list and
  writes a report of them
- **shellcheck** - lints shell scripts
- **make** - for your Makefiles

You also get git and ca-certificates so fetching dependencies over TLS just
works, plus bash, gcc, and musl-dev for scripts and cgo builds.

## Key Considerations

- The tools are pinned to exact versions in the Dockerfile, so they only change when the Dockerfile does
- It's bigger than plain `golang:alpine` since all that tooling has to live
  somewhere
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

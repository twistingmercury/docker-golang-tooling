# golang-tooling

> **Maturity Level**: Emerging - Go build image with security and linting tools

It's `golang:alpine` with all the security and linting tools you'd normally
install yourself already baked in.

## Usage

Grab it from GitHub Container Registry:

```bash
docker pull ghcr.io/twistingmercury/golang-tooling:latest
docker pull ghcr.io/twistingmercury/golang-tooling:go1.27.1
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

## How it works

Instead of installing the same tools in every build, you get them all in one
base image:

- **gosec** - finds security issues in Go code
- **govulncheck** - checks your dependencies for known vulnerabilities
- **goimports** - fixes up your imports
- **golangci-lint** - runs a whole pile of linters at once
- **swag** - generates Swagger docs for Go APIs
- **shellcheck** - lints shell scripts
- **make** - for your Makefiles

You also get git and ca-certificates so fetching dependencies over TLS just
works, plus bash, gcc, and musl-dev for scripts and cgo builds.

## Key Considerations

- The tools are whatever the latest version was when the image got built
- It's bigger than plain `golang:alpine` since all that tooling has to live
  somewhere
- Use a multi-stage build so none of it ends up in your final image

## Development Considerations

### Building

Build it locally with the Makefile, or just call Docker directly.

### Versioning

Here are the tags that get published:

- `latest` - always tracks the newest `golang:alpine`
- **(RECOMMENDED)** `go{GO_VERSION}` - pinned to the Go version that was in
  `golang:alpine` when the image was built (for example, `go1.27.1`)

### GHCR Troubleshooting

If GitHub Actions fails to push with `permission_denied: write_package`, check
these:

1. The `GHCR_PAT` repository secret is set.
2. It's a classic PAT with the `write:packages` and `read:packages` scopes.
3. It also has the `repo` scope if the repository is private.
4. In the package settings for `ghcr.io/twistingmercury/golang-tooling`, this
   repository has write/admin access under Actions access.
5. The repository's Actions workflow permissions are set to read and write.

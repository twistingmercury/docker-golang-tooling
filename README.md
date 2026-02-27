# golang-tooling

> **Maturity Level**: Emerging - Go build image with security and linting tools

A Docker image extending golang:alpine with security scanning and code
quality tools for Go development.

## Usage

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/twistingmercury/golang-tooling:alpine
docker pull ghcr.io/twistingmercury/golang-tooling:go1.26.0-alpine
```

Use as a base image in your Dockerfile:

```dockerfile
FROM ghcr.io/twistingmercury/golang-tooling:alpine AS build
WORKDIR /src
COPY . .
## Run linters, formatters, security scanners, etc
RUN goimports -w .
RUN golangci-lint run
RUN govulncheck ./...
RUN gosec ./...
RUN go test -v ./...
RUN go build -o /app/myapp .

FROM alpine:latest AS runtime
RUN apk add --no-cache ca-certificates
COPY --from=build /app/myapp /usr/local/bin/
ENTRYPOINT ["myapp"]
```

## How it works

This image bundles commonly-used Go security and linting tools into a single
base image, eliminating the need to install them in every build:

- **gosec** - Security scanner for Go code
- **govulncheck** - Vulnerability checker for Go dependencies
- **goimports** - Automatic import formatting
- **golangci-lint** - Comprehensive linting aggregator

The image also includes git and ca-certificates for fetching dependencies and
verifying TLS connections.

## Key Considerations

- Tools are installed at their latest versions at image build time
- Image size is larger than base golang:alpine due to pre-installed tooling
- Use multi-stage builds to keep final runtime images small

## Development Considerations

### Building

Build the image locally using the Makefile or Docker directly.

### Versioning

Published tags:

- `alpine` - rolling tag for the latest `golang:alpine` base
- `go{GO_VERSION}-alpine` - versioned tag derived from the Go version in `golang:alpine` at build time (for example, `go1.26.0-alpine`)

### GHCR Troubleshooting

If GitHub Actions fails to push with `permission_denied: write_package`:

1. Ensure repository secret `GHCR_PAT` is set.
2. Use a classic PAT with scopes `write:packages` and `read:packages`.
3. Add `repo` scope if the repository is private.
4. In the package settings for `ghcr.io/twistingmercury/golang-tooling`, grant this repository write/admin access under Actions access.
5. Confirm repository Actions workflow permissions are set to read and write.

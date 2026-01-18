# golang-tooling

> **Maturity Level**: Emerging - Go build image with security and linting tools

A Docker image extending golang:1.25-alpine with security scanning and code
quality tools for Go development.

## Usage

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/twistingmercury/golang-tooling:v1.0-go1.25-alpine
```

Use as a base image in your Dockerfile:

```dockerfile
FROM ghcr.io/twistingmercury/golang-tooling:v1.0-go1.25-alpine AS build
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

Image tags follow the pattern `{version}-go{go-version}-alpine` (e.g., `v1.0-go1.25-alpine`).

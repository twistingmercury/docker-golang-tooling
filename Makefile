.PHONY: help login build push

BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GO_VERSION := $(or $(shell go env GOVERSION 2>/dev/null | sed 's/^go//'),unknown)
IMAGE_NAME := ghcr.io/twistingmercury/golang-tooling
IMAGE_TAG := alpine

default: help

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mAvailable targets:\033[0m\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

login: ## Log into ghcr.io
	echo ${GITHUB_GHRC_PAT} | docker login ghcr.io -u twistingmercury --password-stdin

build: ## Builds the docker image
	docker build --no-cache --pull \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(GO_VERSION) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) .

	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) go version

push: ## Push the image to ghcr.io/twistingmercury
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

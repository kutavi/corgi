SHELL:=/bin/bash

NAME:=corgi
PKG:=github.com/kutavi/${NAME}
MAINCMD:=./cmd/${NAME}

GO111MODULE:=on
export GO111MODULE
CGO_ENABLED:=0
export CGO_ENABLED

# Flags and Version
BRANCH:=$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
COMMIT_SHORT:=$(shell git rev-parse --short HEAD 2>/dev/null)
COMMIT:=$(shell git rev-parse HEAD 2>/dev/null)
TAG:=$(shell git describe --tags 2>/dev/null)
VER_FLAGS=-X '${PKG}/internal.Branch=${BRANCH}' -X '${PKG}/internal.Commit=${COMMIT}' -X '${PKG}/internal.CommitShort=${COMMIT_SHORT}' -X '${PKG}/internal.Tag=${TAG}'
GO_LDFLAGS=-ldflags "${VER_FLAGS} -extldflags -static"

GO:=go
GO_EXEC=${GO}
export GO_EXEC
DOCKER:=docker
COMPOSE:=docker-compose
COMPOSE_PROJECT_NAME?=${NAME}
export COMPOSE_PROJECT_NAME

IMAGE:=kutavi/${NAME}
export IMAGE
IMAGE_TAG?=latest
export IMAGE_TAG
IMAGE_CI:=kutavi/${NAME}-ci
export IMAGE_CI

.PHONY: default
default: build

.PHONY: env
env:
	$(GO) env

.PHONY: mod
mod:
	$(GO) mod tidy
	$(GO) mod verify

.PHONY: vendor
vendor:
	$(GO) mod vendor

.PHONY: build
build:
	$(GO) build -mod=vendor ${GO_LDFLAGS} -o ${NAME} ${MAINCMD}

.PHONY: clean
clean:
	rm -f ${NAME}

#@go get golang.org/x/tools/cmd/goimports
.PHONY: goimports
goimports:
	@./scripts/goimports

.PHONY: gofmt
gofmt:
	@./scripts/gofmt

.PHONY: fmt
fmt: goimports gofmt

#@go get honnef.co/go/tools/cmd/staticcheck
.PHONY: staticcheck
staticcheck:
	@./scripts/staticcheck

#@go get -u golang.org/x/lint/golint
.PHONY: lint
lint:
	@./scripts/golint

.PHONY: golangci-lint
golangci-lint:
	golangci-lint run

.PHONY: vet
vet:
	@echo ">>> go vet <<<"
	@$(GO) vet ${PACKAGES}
	@echo ""

.PHONY: checks
checks: fmt staticcheck lint vet

#@go get github.com/client9/misspell/cmd/misspell
.PHONY: spellcheck
spellcheck:
	@misspell -locale="US" -error -source="text" $(FOLDERS)

.PHONY: test test-integration
test-integration: TEST_TAGS=integration
test test-integration:
	$(GO) test -timeout 60s -tags="${TEST_TAGS}" -coverprofile cover.out -covermode atomic ${PACKAGES}
	$(GO) tool cover -func cover.out
	rm cover.out

########################
### Docker / Compose ###
.PHONY: up
.PHONY: image
image:
	$(DOCKER) build . -f build/package/Dockerfile -t ${IMAGE}:${IMAGE_TAG}

.PHONY: image-ci
image-ci:
	$(DOCKER) build . -f build/ci/Dockerfile -t ${IMAGE_CI}:latest

up: image image-ci
	$(COMPOSE) -f deploy/local/docker-compose.yml up

.PHONY: down
down:
	$(COMPOSE) -f deploy/local/docker-compose.yml down --volumes

dockerized-%:
	$(DOCKER) run --rm -it -v $(shell pwd):/app:ro -w /app ${IMAGE_CI}:latest $(subst dockerized-,,$@)
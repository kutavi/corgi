SHELL := /bin/bash

NAME := corgi
PKG := github.com/kutavi/${NAME}
MAINCMD := ./cmd/${NAME}

GO111MODULE := on
export GO111MODULE
CGO_ENABLED := 0
export CGO_ENABLED
VERSION?=0.0.1
VER_FLAGS=-X ${PKG}/version=${VERSION}
GO_LDFLAGS=-ldflags "-w -s ${VER_FLAGS}"
GO_LDFLAGS_STATIC=-ldflags "-w -s ${VER_FLAGS} -extldflags -static"
TEST_TAGS :=

GO := go
DOCKER := docker
COMPOSE := docker-compose

IMAGE := ${NAME}
IMAGE_TAG := latest

PACKAGES = $(shell $(GO) list ./... | grep -v vendor)
FOLDERS = $(shell go list -f '{{.Dir}}' ./... | grep -v vendor)

.PHONY: default
default: static

.PHONY: env
env:
	$(GO) env

.PHONY: test test-integration
test-integration: TEST_TAGS=integration
test test-integration:
	$(GO) test -timeout 60s -tags="${TEST_TAGS}" ${PACKAGES}

.PHONY: test-coverage test-coverage-integration
test-coverage-integration: TEST_TAGS=integration
test-coverage test-coverage-integration:
	$(GO) test -timeout 60s -tags="${TEST_TAGS}" -coverprofile cover.out -covermode atomic ${PACKAGES}
	$(GO) tool cover -func cover.out
	rm cover.out

#@go get golang.org/x/tools/cmd/goimports
.PHONY: goimports
goimports:
	@echo ">>> goimports <<<"
	@DIFFS="$$(goimports -d -e $(FOLDERS))"; \
		if [[ -n "$${DIFFS}" ]]; then \
			echo "$${DIFFS}"; \
			echo -e "\n"; \
			echo "goimports errors. Run the below command to fix them:"; \
			echo "goimports -w $(FOLDERS)"; \
			exit 1; \
		fi
	@echo ""

.PHONY: gofmt
gofmt:
	@echo ">>> gofmt <<<"
	@DIFFS="$$(gofmt -d $(FOLDERS))"; \
		if [[ -n "$${DIFFS}" ]]; then \
			echo "$${DIFFS}"; \
			echo -e "\n"; \
			echo "gofmt errors. Run the below command to fix them:"; \
			echo "gofmt -s -w $(FOLDERS)"; \
			exit 1; \
		fi
	@echo ""

.PHONY: fmt
fmt: goimports gofmt

#@go get honnef.co/go/tools/cmd/staticcheck
.PHONY: staticcheck
staticcheck:
	@echo ">>> staticcheck <<<"
	@staticcheck -checks="all" -tests $(FOLDERS)
	@echo ""

#@go get -u golang.org/x/lint/golint
.PHONY: lint
lint:
	@echo ">>> golint <<<"
	@test -z "$$(golint ${PACKAGES} | tee /dev/stderr)" || exit 1
	@echo ""

.PHONY: dockerized-lint-ci
dockerized-lint-ci:
	$(DOCKER) run --rm -t -v $(shell pwd):/app:ro -w /app golangci/golangci-lint:v1.27.0 golangci-lint run

.PHONY: vet
vet:
	@echo ">>> go vet <<<"
	@$(GO) vet ${PACKAGES}
	@echo ""

.PHONY: checks
checks: fmt staticcheck lint vet

.PHONY: dockerized-checks
dockerized-checks: mod vendor
	$(DOCKER) run --rm -it -v $(shell pwd):/app:ro -w /app ${NAME}-tests make checks

#@go get github.com/client9/misspell/cmd/misspell
.PHONY: spellcheck
spellcheck:
	@misspell -locale="US" -error -source="text" $(FOLDERS)

.PHONY: mod
mod:
	$(GO) mod tidy
	$(GO) mod verify

.PHONY: vendor
vendor:
	$(GO) mod vendor

.PHONY: build
build:
	$(GO) build -a -mod=vendor ${GO_LDFLAGS} -o ${NAME} ${MAINCMD}

.PHONY: static
static:
	$(GO) build -a -mod=vendor ${GO_LDFLAGS_STATIC} -o ${NAME} ${MAINCMD}

.PHONY: clean
clean:
	rm -f ${NAME}

.PHONY: image
image:
	$(DOCKER) build . -f .docker/Dockerfile -t ${IMAGE}:${IMAGE_TAG}

.PHONY: image-tests
image-tests:
	$(DOCKER) build --no-cache . -f .docker/Dockerfile.tests -t ${NAME}-tests:latest

.PHONY: up
up:
		$(COMPOSE) -f .docker/docker-compose.yml up --force-recreate --build

.PHONY: down
down:
		$(COMPOSE) -f .docker/docker-compose.yml down --volumes

default: build

GO111MODULE?=on
export GO111MODULE

CGO_ENABLED?=0
export CGO_ENABLED

GOOS?=linux
export GOOS

GOARCH?=amd64
export GOARCH

EXEC?=corgi
MAINCMD?=./cmd/corgi

env:
		go env

test:
		go test -timeout 60s $$(go list ./...)

test-coverage:
		go test -timeout 60s -coverprofile cover.out -covermode atomic $$(go list ./...)
		go tool cover -func cover.out
		rm cover.out

fmt:
		go fmt $$(go list ./...)

lint:
		golint $$(go list ./...)

vet:
		go vet $$(go list ./...)

mod:
		go mod tidy
		go mod verify

vendor: mod
		go mod vendor

build: vendor
		go build -a -v -mod=vendor -o $(EXEC) $(MAINCMD)

run: vendor
		go run -mod=vendor $(MAINCMD)

clean:
		rm -f $(EXEC)

install:
		cp $(EXEC) /usr/local/bin

uninstall:
		rm -f /usr/local/bin/$(EXEC)

.PHONY: env test fmt lint vet mod vendor build run clean install uninstall

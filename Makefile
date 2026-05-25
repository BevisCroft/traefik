# Traefik Makefile

# Variables
BINARY_NAME := traefik
BUILD_DIR := dist
GO := go
GOFLAGS := -v
GOTEST := $(GO) test
GOBUILD := $(GO) build
GOVET := $(GO) vet
GOFMT := gofmt

# Version information
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE := $(shell date -u '+%Y-%m-%dT%H:%M:%SZ')

# Build flags
LD_FLAGS := -ldflags "-X github.com/traefik/traefik/v3/pkg/version.Version=$(VERSION) \
	-X github.com/traefik/traefik/v3/pkg/version.Commit=$(COMMIT) \
	-X github.com/traefik/traefik/v3/pkg/version.Date=$(DATE)"

.PHONY: all build clean test lint fmt vet help docker-build

## all: Build the binary
all: clean build

## build: Compile the binary
build:
	@echo "Building $(BINARY_NAME) $(VERSION)..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(GOFLAGS) $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/traefik/

## build-linux: Cross-compile for Linux
build-linux:
	@echo "Building $(BINARY_NAME) for Linux..."
	@mkdir -p $(BUILD_DIR)
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/traefik/

## build-darwin: Cross-compile for macOS
build-darwin:
	@echo "Building $(BINARY_NAME) for macOS..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 ./cmd/traefik/

## build-darwin-arm: Cross-compile for macOS Apple Silicon
build-darwin-arm:
	@echo "Building $(BINARY_NAME) for macOS (arm64)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 ./cmd/traefik/

## test: Run unit tests
test:
	@echo "Running tests..."
	$(GOTEST) $(GOFLAGS) ./...

## test-race: Run tests with race detector
test-race:
	@echo "Running tests with race detector..."
	$(GOTEST) -race ./...

## test-coverage: Run tests with coverage report
test-coverage:
	@echo "Running tests with coverage..."
	$(GOTEST) -coverprofile=coverage.out ./...
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

## lint: Run linter
lint:
	@echo "Running linter..."
	@which golangci-lint > /dev/null || (echo "golangci-lint not found, install from https://golangci-lint.run/" && exit 1)
	golangci-lint run ./...

## fmt: Format Go source code
fmt:
	@echo "Formatting code..."
	$(GOFMT) -w -s .

## vet: Run go vet
vet:
	@echo "Running go vet..."
	$(GOVET) ./...

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f coverage.out coverage.html

## deps: Download dependencies
deps:
	@echo "Downloading dependencies..."
	$(GO) mod download
	$(GO) mod tidy

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t traefik:$(VERSION) .

## generate: Run go generate
generate:
	@echo "Running go generate..."
	$(GO) generate ./...

## help: Display this help message
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | column -t -s ':'

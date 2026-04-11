.PHONY: test-docker build-docker shell-docker test-local test-local-shell test-local-clean test-clean test-clean-fast test-clean-shell clean help

CLEAN_TEST_IMAGE := dotfiles-clean-test
PLATFORM := linux/amd64

help:
	@echo "Dotfiles Testing Commands:"
	@echo ""
	@echo "  In-container fast checks (run from inside the dev container):"
	@echo "    make test-local       - chezmoi apply against /workspace with isolated HOME (fast, no brew install)"
	@echo "    make test-local-shell - Open zsh with the isolated HOME for manual inspection"
	@echo "    make test-local-clean - Remove the isolated HOME and chezmoi binary"
	@echo ""
	@echo "  Clean-room E2E (run from the HOST — needs docker):"
	@echo "    make test-clean       - Spin up a clean Ubuntu container, full bootstrap including brew install (slow)"
	@echo "    make test-clean-fast  - Same but skip brew install (fast smoke test)"
	@echo "    make test-clean-shell - Open shell in the clean-room container (for debugging)"
	@echo ""
	@echo "  Legacy Ubuntu+brew test image (clones from GitHub):"
	@echo "    make build-docker     - Build the Ubuntu+brew test image"
	@echo "    make test-docker      - Run automated tests in it"
	@echo "    make shell-docker     - Open interactive shell in it"
	@echo "    make clean            - Remove Docker test image"

test-local:
	./dev-test-local.sh

test-local-shell:
	./dev-test-local.sh --shell

test-local-clean:
	./dev-test-local.sh --clean

# ---- Clean-room E2E test ----
# Builds a fresh Ubuntu container with NO chezmoi/brew/dotfiles pre-installed,
# bind-mounts the local repo, and runs the full bootstrap.

build-clean-test:
	@echo "Building $(CLEAN_TEST_IMAGE)..."
	docker build --platform $(PLATFORM) -f Dockerfile.clean-test -t $(CLEAN_TEST_IMAGE) .

test-clean: build-clean-test
	@echo "Running clean-room E2E test (full install, ~10min)..."
	docker run --rm \
		--platform $(PLATFORM) \
		-v "$(CURDIR)":/dotfiles:ro \
		$(CLEAN_TEST_IMAGE)

test-clean-fast: build-clean-test
	@echo "Running clean-room smoke test (skipping brew install)..."
	docker run --rm \
		--platform $(PLATFORM) \
		-v "$(CURDIR)":/dotfiles:ro \
		-e SKIP_BREW=1 \
		$(CLEAN_TEST_IMAGE)

test-clean-shell: build-clean-test
	@echo "Opening shell in clean-room container..."
	@echo "  cd /dotfiles to inspect the source"
	@echo "  ~/entrypoint.sh to run the full test"
	docker run --rm -it \
		--platform $(PLATFORM) \
		-v "$(CURDIR)":/dotfiles:ro \
		--entrypoint /bin/bash \
		$(CLEAN_TEST_IMAGE)

build-docker:
	@echo "Building Docker test image..."
	docker build -f Dockerfile.test -t dotfiles-test .

test-docker: build-docker
	@echo "Running dotfiles tests in Docker..."
	docker run --rm dotfiles-test

shell-docker: build-docker
	@echo "Opening interactive shell in Docker..."
	@echo "You can manually run: chezmoi init https://github.com/soya-miyoshi/dotfiles.git"
	docker run --rm -it dotfiles-test /bin/bash

clean:
	@echo "Removing Docker test image..."
	docker rmi dotfiles-test || true

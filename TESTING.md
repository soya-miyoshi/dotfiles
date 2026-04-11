# Testing Dotfiles Locally with Docker

This guide shows how to test your dotfiles locally using Docker with Homebrew installed.

## Prerequisites

- Docker installed on your machine
- Make (optional, but recommended)

## Quick Start

### Using Make (Recommended)

```bash
# Run automated tests
make test-docker

# Open interactive shell for manual testing/debugging
make shell-docker

# Build the image only
make build-docker

# Clean up
make clean
```

### Using Docker Directly

```bash
# Build the test image
docker build -f Dockerfile.test -t dotfiles-test .

# Run automated tests
docker run --rm dotfiles-test

# Open interactive shell
docker run --rm -it dotfiles-test /bin/bash
```

## What Gets Tested

The automated test script (`test-dotfiles.sh`) verifies:

1. ✓ Homebrew is installed and working
2. ✓ chezmoi is installed and working
3. ✓ `chezmoi init https://github.com/soya-miyoshi/dotfiles.git` succeeds
4. ✓ `chezmoi cd` (changing to source directory) works
5. ✓ `chezmoi apply` succeeds

## Interactive Testing

When you run `make shell-docker`, you'll get a bash shell inside a Docker container with:

- Ubuntu 22.04
- Homebrew installed and configured
- chezmoi installed

You can manually test your dotfiles:

```bash
# Inside the Docker container
brew --version              # Verify Homebrew works
chezmoi --version          # Verify chezmoi works

# Test your dotfiles
chezmoi init https://github.com/soya-miyoshi/dotfiles.git
chezmoi apply --dry-run    # See what would change
chezmoi apply --verbose    # Apply dotfiles
```

## Debugging Failed Tests

If tests fail, use the interactive shell:

```bash
make shell-docker
```

Then manually run each command to see where it fails:

```bash
chezmoi init https://github.com/soya-miyoshi/dotfiles.git
cd $(chezmoi source-path)
ls -la                      # See what files were cloned
chezmoi apply --dry-run     # Preview changes
chezmoi apply --verbose     # Apply and see details
```

## Limitations

**What Docker Testing Can Verify:**
- Dotfiles can be initialized and applied
- Scripts run without errors (on Linux)
- Homebrew-based installations work

**What Docker Testing Cannot Verify:**
- macOS-specific functionality (use GitHub Actions for this)
- GUI applications
- System-level configurations
- Interactive prompts

## CI/CD Testing

For comprehensive testing, push to GitHub. The workflow tests:
- macOS (using native macOS runners)
- Linux (using Docker and native Ubuntu)

See `.github/workflows/test-dotfiles.yml` for details.

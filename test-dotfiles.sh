#!/bin/bash
set -e

# CI / minimal-mode: skip secrets and heavy installs
export CHEZMOI_NO_SECRETS=1
export CI=1

echo "================================"
echo "Testing Dotfiles Installation"
echo "================================"

# Check if brew is installed
echo "Checking Homebrew installation..."
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is installed"
    brew --version
else
    echo "✗ Homebrew is not installed"
    exit 1
fi

# Check if chezmoi is installed
echo ""
echo "Checking chezmoi installation..."
if command -v chezmoi &> /dev/null; then
    echo "✓ chezmoi is installed"
    chezmoi --version
else
    echo "✗ chezmoi is not installed"
    exit 1
fi

# Initialize chezmoi with your dotfiles
echo ""
echo "Initializing chezmoi with dotfiles..."
chezmoi init --no-tty --promptDefaults https://github.com/soya-miyoshi/dotfiles.git

if [ $? -eq 0 ]; then
    echo "✓ chezmoi init succeeded"
else
    echo "✗ chezmoi init failed"
    exit 1
fi

# Change to chezmoi directory
echo ""
echo "Changing to chezmoi directory..."
cd "$(chezmoi source-path)"

if [ $? -eq 0 ]; then
    echo "✓ chezmoi cd succeeded"
    echo "Current directory: $(pwd)"
else
    echo "✗ chezmoi cd failed"
    exit 1
fi

# Apply dotfiles (dry-run first to see what would happen)
echo ""
echo "Running chezmoi apply --dry-run..."
chezmoi apply --no-tty --dry-run

# Apply dotfiles for real
echo ""
echo "Applying dotfiles..."
chezmoi apply --no-tty --verbose

if [ $? -eq 0 ]; then
    echo "✓ chezmoi apply succeeded"
else
    echo "✗ chezmoi apply failed"
    exit 1
fi

echo ""
echo "================================"
echo "All tests passed!"
echo "================================"

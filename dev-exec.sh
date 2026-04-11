#!/bin/bash
# DO NOT EDIT in forked projects. This file is maintained in the upstream template repository.

# Script to exec into the devcontainer
# Usage: ./dev-exec.sh [command]
# If no command is provided, opens an interactive zsh shell

# Load PROJECT_NAME from .env if present
if [ -f "$(dirname "$0")/.env" ]; then
  # shellcheck disable=SC1091
  . "$(dirname "$0")/.env"
fi
CONTAINER_NAME="${PROJECT_NAME:-my-saas}-devcontainer"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '${CONTAINER_NAME}' is not running."
    echo ""
    echo "Start the container with:"
    echo "  docker-compose up -d"
    exit 1
fi

# If no arguments provided, open interactive zsh shell
if [ $# -eq 0 ]; then
    echo "Opening interactive shell in ${CONTAINER_NAME}..."
    docker exec -it "${CONTAINER_NAME}" /bin/zsh
else
    # Execute the provided command
    docker exec -it "${CONTAINER_NAME}" "$@"
fi

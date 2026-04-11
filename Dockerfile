# DO NOT EDIT in forked projects. This file is maintained in the upstream template repository.
FROM node:24-bookworm

ARG TZ=Asia/Tokyo
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0

# Timezone
ENV TZ=${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    vim \
    sudo \
    # Build tools for native modules (bcrypt, etc.)
    build-essential \
    python3 \
    python3-dev \
    libssl-dev \
    # Process management
    lsof \
    procps \
    psmisc \
    # Playwright system dependencies for Chromium
    libnspr4 \
    libnss3 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxkbcommon0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Install git-delta for better diffs
RUN wget -q https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_amd64.deb \
    && dpkg -i git-delta_${GIT_DELTA_VERSION}_amd64.deb \
    && rm git-delta_${GIT_DELTA_VERSION}_amd64.deb

# Install zsh-in-docker
RUN wget -q https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh \
    && sh zsh-in-docker.sh \
        -t robbyrussell \
        -p git \
        -p https://github.com/zsh-users/zsh-autosuggestions \
        -p https://github.com/zsh-users/zsh-syntax-highlighting \
    && rm zsh-in-docker.sh

# Create workspace and persistent directories
RUN mkdir -p /workspace /commandhistory /home/node/.claude \
    && chown -R node:node /workspace /commandhistory /home/node/.claude

# Symlink .claude.json into the volume-mounted .claude/ directory
RUN ln -s /home/node/.claude/.claude.json /home/node/.claude.json \
    && chown -h node:node /home/node/.claude.json

# Allow node user to run sudo without password (useful for apt installs during dev)
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

# Configure npm global directory
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=/home/node/.local/bin:$NPM_CONFIG_PREFIX/bin:$PATH
RUN mkdir -p $NPM_CONFIG_PREFIX && chown -R node:node $NPM_CONFIG_PREFIX

# --- Everything below runs as node user ---
USER node

# Install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/node/.fzf \
    && /home/node/.fzf/install --all

# Shell config
RUN echo 'export HISTFILE=/commandhistory/.bash_history' >> /home/node/.bashrc \
    && echo 'alias cds="claude --dangerously-skip-permissions"' >> /home/node/.bashrc \
    && echo 'alias cds="claude --dangerously-skip-permissions"' >> /home/node/.zshrc \
    && echo 'PROMPT="%F{green}%n%f:%F{blue}%~%f %# "' >> /home/node/.zshrc

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install pnpm + Playwright globally, download Chromium
RUN npm install -g pnpm@10.30.2 playwright@1.55.0 \
    && npx playwright install chromium

# Git config (delta + settings + identity)
RUN git config --global core.pager delta \
    && git config --global interactive.diffFilter "delta --color-only" \
    && git config --global delta.navigate true \
    && git config --global delta.side-by-side true \
    && git config --global init.defaultBranch main \
    && git config --global pull.rebase false \
    && git config --global push.autoSetupRemote true \
    && git config --global core.autocrlf input \
    && git config --global core.hooksPath /home/node/.git-hooks \
    && git config --global --add safe.directory /workspace \
    && git config --global user.email "soyamiyoshi@gmail.com" \
    && git config --global user.name "soya-miyoshi"

# Pre-push hook to prevent accidental pushes from container
RUN mkdir -p /home/node/.git-hooks \
    && printf '%s\n' '#!/bin/bash' 'echo "Push is disabled inside container. Run from host."' 'exit 1' \
       > /home/node/.git-hooks/pre-push \
    && chmod +x /home/node/.git-hooks/pre-push

ENV EDITOR=vim
WORKDIR /workspace
SHELL ["/bin/zsh", "-c"]

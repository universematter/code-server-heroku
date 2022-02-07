# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

ENV SHELL=/bin/bash
ENV NODE_VERSION lts/*

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

RUN code-server --install-extension shan.code-settings-sync

RUN curl -fsSL https://deno.land/x/install/install.sh | sh

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    chmod +x $HOME/.nvm/nvm.sh && \
    . $HOME/.nvm/nvm.sh && \
    nvm install --latest-npm "$NODE_VERSION" && \
    npm install -g yarn

#RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
#RUN sudo apt-get install -y \
#    nodejs \
#    yarnpkg


RUN echo "----- INSTALLED -----" && \
    echo "\nNODE=" && node --version && \
    echo "\nNPM=" && npm --version && \
    echo "\nYARN=" && yarn --version

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]

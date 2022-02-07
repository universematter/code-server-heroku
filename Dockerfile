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
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# RUN bash -c 'source $HOME/.nvm/nvm.sh \
#    && nvm install --latest-npm "$NODE_VERSION" \
#    && nvm alias default "$NODE_VERSION" \
#    && nvm use default'
#     && DEFAULT_NODE_VERSION=$(nvm version default) \
#     && ln -sf $NVM_DIR/versions/node/$DEFAULT_NODE_VERSION/bin/node /usr/bin/nodejs \
#     && ln -sf $NVM_DIR/versions/node/$DEFAULT_NODE_VERSION/bin/node /usr/bin/node \
#     && ln -sf $NVM_DIR/versions/node/$DEFAULT_NODE_VERSION/bin/npm /usr/bin/npm \
#     && npm install -g yarn

RUN code-server --install-extension shan.code-settings-sync

RUN curl -fsSL https://deno.land/x/install/install.sh | sh

RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt update && sudo apt-get install -y \
    nodejs \
    yarn

SHELL ["/bin/bash", "--login", "-c"]
    
RUN echo "----- INSTALLED -----" \
    && echo "\nNODE=" && node --version \
    && echo "\nNPM=" && npm --version \
    && echo "\nYARN=" && yarn --version

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]

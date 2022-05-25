#!/usr/bin/env bash

echo "Installing Docker Compose" && \
mkdir -p ~/.docker/cli-plugins/ && \
curl -SL https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && \
chmod +x ~/.docker/cli-plugins/docker-compose && \
docker compose version

#!/usr/bin/env bash

# Update package manager
echo "Updating packages" && \
apt update && \
apt upgrade -y && \

docker --version || source /home/zzub/setup-scripts/1-install-docker.sh && \
docker compose version || source /home/zzub/setup-scripts/2-install-docker-compose.sh && \

# Run docker compose
echo "Running docker compose" && \
cd /home/zzub/docker && \
docker compose -f docker-compose.yaml build && \
docker compose -f docker-compose.yaml up

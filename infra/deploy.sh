#!/bin/bash
set -e
cd /app/promptfill
. ./.env
mv infra/docker-compose.prod.yml docker-compose.yml 2>/dev/null || true
echo "$GH_PAT" | docker login ghcr.io -u "$GH_OWNER" --password-stdin
docker compose pull
docker compose up -d --force-recreate
docker image prune -f
rm -f .env
echo "Deployment complete!"

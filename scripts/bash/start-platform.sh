#!/usr/bin/env bash
# Start the whole platform: core + shared gateway (http://localhost:8000),
# then every team stack (detached).  Run:  scripts/bash/start-platform.sh [team numbers...]
#   scripts/bash/start-platform.sh          # all 8 teams
#   scripts/bash/start-platform.sh 2 5      # only teams 2 and 5
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
teams=("$@"); [ ${#teams[@]} -gt 0 ] || teams=(1 2 3 4 5 6 7 8)

echo "==> core + shared gateway"
docker compose -f "$root/deploy/docker-compose.yml" up -d --build

# Team 2 builds from the repo root and reads ../../.env
[ -f "$root/.env" ] || cp "$root/.env.example" "$root/.env"

for i in "${teams[@]}"; do
    dir="$root/teams/team$i"
    [ -d "$dir" ] || { echo "team$i missing, skipping"; continue; }
    ( cd "$dir"
      [ -f .env ] || cp .env.example .env
      echo "==> team$i"
      docker compose up -d --build )
done
echo "Platform is up: http://localhost:8000  (team APIs under /api/teamN/)"

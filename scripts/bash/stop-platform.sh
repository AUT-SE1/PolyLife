#!/usr/bin/env bash
# Stop the teams and the core + shared gateway started by start-platform.sh.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
for i in 1 2 3 4 5 6 7 8; do
    [ -d "$root/teams/team$i" ] || continue
    ( cd "$root/teams/team$i" && docker compose down )
done
docker compose -f "$root/deploy/docker-compose.yml" down

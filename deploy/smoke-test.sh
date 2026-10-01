#!/usr/bin/env bash
# Logs in through the shared gateway and prints the status of each team route.
# Usage: deploy/smoke-test.sh [user] [password]    (defaults: seeded user1)
set -uo pipefail
BASE="${BASE:-http://localhost:8000}"
user="${1:-user1}"; pass="${2:-user1pass}"

body=$(curl -s -X POST "$BASE/api/login" -H 'Content-Type: application/json' \
       -d "{\"username\":\"$user\",\"password\":\"$pass\"}")
token=$(printf '%s' "$body" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("access") or d.get("tokens",{}).get("access") or d.get("token",""))' 2>/dev/null)
[ -n "$token" ] || { echo "login failed (check the field names in core/auth_views.py): $body"; exit 1; }
echo "logged in as $user"

# <path>  (200 = reachable + authenticated; 502 = that team's service is not running)
paths=(/api/team1/whoami /api/team2/auth-test/ /api/team3/whoami /api/team4/cart/
       /api/team5/whoami/ /api/team6/health /api/team7/meta/auth-smoke /api/team8/whoami)
for p in "${paths[@]}"; do
    anon=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$p")
    auth=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $token" "$BASE$p")
    printf '%-28s no-token=%s  with-token=%s\n' "$p" "$anon" "$auth"
done

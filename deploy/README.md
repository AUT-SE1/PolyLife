# deploy/ — core + shared gateway

One entry point for the whole platform: **http://localhost:8000**.

```
browser ─► gateway (nginx :8000)
             ├─ /api/teamN/…  ─ auth_request ─► core /api/verify ─► teamN-backend:8000
             └─ everything else (login, SPA, admin) ─────────────► core:8000
```

* The core is no longer published on a host port; only the gateway is.
* The gateway asks the core to verify the JWT (header or cookie) for every
  `/api/teamN/…` request, **overwrites** `X-User-Id` / `X-User-Username` with the
  verified values, and strips them on public routes, so services can trust them.
* Team services are reached on the shared `polylife_net` network by the alias
  `teamN-backend`. Team services are never published on a host port.
* Unknown `/api/teamN/` → 404, a team that is down → 502 (the gateway keeps running).

## Run

```bash
scripts/bash/start-platform.sh          # core + gateway + all 8 teams
scripts/bash/start-platform.sh 2 5      # core + gateway + only teams 2 and 5
deploy/smoke-test.sh                    # logs in as user1 and probes every team
scripts/bash/stop-platform.sh
```

The per-team gateways on `910N` still work for each team's own UI.

## Public path → service path

| Team | Public path | Service receives | Notes |
|------|-------------|------------------|-------|
| 1, 3, 5, 6, 8 | `/api/teamN/<rest>` | `/api/<rest>` | team 6 `/health` is public; team 8 also gets `X-Gateway-Secret` |
| 2 | `/api/team2/<rest>` | unchanged | `/api/team2/health/` public |
| 4 | `/api/team4/<rest>` | `/api/<rest>` | `store/`, `supplements/` and `health/` are public except their `admin/` subtrees |
| 7 | `/api/team7/<rest>` | `/<rest>` | FastAPI; WebSocket upgrade + long read timeout |

## What a team must provide

In its `docker-compose.yml`, the backend joins `polylife_net` with an alias:

```yaml
backend:
  networks:
    team:
    polylife:
      aliases: [teamN-backend]
```

Teams 1 and 3 have this in their commented-out `backend` block — keep it when you enable it.

## Notes

* `TEAM8_GATEWAY_SECRET` (default = team 8's `.env.example` value) must equal
  `GATEWAY_SHARED_SECRET` in `teams/team8/.env`.
* Route table: `gateway.conf.template`. After editing, `docker compose -f deploy/docker-compose.yml restart gateway`.
* The core's `TEAM_APPS` mounting (`core/db_router.py`) is kept but unused by this layout.

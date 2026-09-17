# CodeAlpha_DockerWebServer

Task 4 of the CodeAlpha DevOps internship: deploy and manage a web server inside
Docker containers.

The application is a small Express server that returns its own container
identity. That choice is deliberate — the page shows the hostname, uptime and
environment of whichever container answered the request, which makes container
lifecycle and replica behaviour visible in the browser rather than only in the
terminal.

## What this project demonstrates

| Requirement | Where it lives |
| --- | --- |
| Containerisation basics | `Dockerfile` — multi-stage build on `node:20-alpine` |
| Image hygiene | `.dockerignore`, dependency stage discarded from final image |
| Container security | runs as the unprivileged `node` user, not root |
| Lifecycle commands | "Container lifecycle" section below |
| Health monitoring | `HEALTHCHECK` instruction + `/healthz` endpoint |
| Orchestration | `docker-compose.yml` with a bridge network and named volume |
| Graceful shutdown | `SIGTERM` handler in `server.js` |

## Requirements

- Docker Desktop (or Docker Engine 20.10+)
- No local Node.js install needed — the build happens inside the image

## Quick start

```bash
# Build the image
docker build -t codealpha-webserver:1.0 .

# Run it, mapping host port 8080 to container port 3000
docker run -d --name webserver -p 8080:3000 codealpha-webserver:1.0
```

Open <http://localhost:8080>. The health indicator should turn solid within a
couple of seconds.

With Compose instead:

```bash
docker compose up -d --build
docker compose ps
docker compose down
```

## Container lifecycle

These are the commands to walk through in the demo video.

```bash
docker ps                      # running containers
docker ps -a                   # including stopped ones
docker stop webserver          # graceful stop (SIGTERM)
docker start webserver         # restart the same container
docker restart webserver
docker logs -f webserver       # follow stdout
docker exec -it webserver sh   # shell inside the running container
docker inspect webserver       # full JSON config and state
docker stats webserver         # live CPU / memory usage
docker rm -f webserver         # remove the container
docker images                  # local images
docker rmi codealpha-webserver:1.0
```

Point worth making on camera: `docker stop` followed by `docker start` preserves
the container's filesystem, while `docker rm` discards it. Data that must
survive removal belongs in a volume — which is what `weblogs` in the Compose
file is for.

## Health monitoring

The `HEALTHCHECK` in the Dockerfile polls `/healthz` every 30 seconds. Docker
surfaces the result in the `STATUS` column:

```bash
docker ps
# STATUS -> "Up 45 seconds (health: starting)" then "Up 2 minutes (healthy)"
```

To read the recorded probe history:

```bash
docker inspect --format '{{json .State.Health}}' webserver
```

To demonstrate an *unhealthy* container on camera, temporarily change the
healthcheck URL in the Dockerfile to a path that does not exist (for example
`/nope`), rebuild, and watch the status flip to `unhealthy` after the retries are
exhausted. Revert it afterwards.

## Running multiple replicas

Because the page reports its own hostname, replicas are easy to show:

```bash
# Remove the "ports" block from docker-compose.yml first - published ports
# cannot be shared by multiple replicas of the same service.
docker compose up -d --scale web=3
docker compose ps
```

Each container reports a different Host ID.

## Troubleshooting

**`port is already allocated`** — something else holds host port 8080. Map a
different one: `-p 8081:3000`.

**Page loads but the indicator says no response** — the server is not listening
on the interface Docker forwards to. Confirm `server.js` binds `0.0.0.0` rather
than `localhost`; a container that binds only to loopback is unreachable from
the host.

**Container exits immediately** — read `docker logs webserver`. A container
lives only as long as its main process, so any startup crash stops it.

**Health status stuck on `starting`** — that is expected during
`--start-period`. If it never becomes `healthy`, run the healthcheck command
manually inside the container: `docker exec webserver wget --spider http://localhost:3000/healthz`.

## Project structure

```
.
├── Dockerfile              # multi-stage build definition
├── .dockerignore           # files kept out of the build context
├── docker-compose.yml      # single-service orchestration
├── package.json
├── server.js               # Express app and /healthz endpoint
└── public/
    └── index.html          # landing page
```

## Notes

Dependencies are installed with `npm install --omit=dev`. Running `npm install`
locally once will produce a `package-lock.json`; commit it and the Dockerfile
line can be tightened to `npm ci --omit=dev` for fully reproducible builds.

---

Submitted for the CodeAlpha DevOps Internship — Task 4.

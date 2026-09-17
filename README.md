# CodeAlpha_DockerWebServer

**CodeAlpha DevOps Internship — Task 4: Web Server using Docker**

A small Express web app, containerized with Docker, that displays live
information about the container running it (hostname, uptime, health status).
This README doubles as a step-by-step guide — if you're learning Docker like I
am, you should be able to follow it and get the same result.

## What this project shows

- Building a Docker image with a **Dockerfile**
- Running a container and mapping it to a browser port
- A working **health check** that Docker monitors automatically
- Basic container lifecycle commands (start, stop, logs, inspect)
- Running the app with **Docker Compose** instead of long manual commands

## Project structure

```
.
├── Dockerfile              # instructions Docker follows to build the image
├── .dockerignore           # files Docker should ignore when building
├── docker-compose.yml      # one-command way to start the container
├── package.json            # lists the app's dependencies (Express)
├── server.js               # the actual web server code
├── README.md
└── public/
    └── index.html          # the webpage a visitor sees
```

## How I built this, step by step

### 1. Installed the tools
- [Git](https://git-scm.com/) — to push code to GitHub
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — to build and run containers

Checked both installed correctly:
```bash
git --version
docker --version
```

### 2. Created the GitHub repository
Created a new **public** repo named `CodeAlpha_DockerWebServer`, with a
`.gitignore` set to Node, so files like `node_modules` never get uploaded.

### 3. Cloned it to my computer
```bash
git clone https://github.com/<your-username>/CodeAlpha_DockerWebServer.git
cd CodeAlpha_DockerWebServer
```

### 4. Wrote the app
`server.js` is a small [Express](https://expressjs.com/) server. It does two things:
- Serves the webpage in `public/index.html`
- Exposes a `/healthz` endpoint that returns JSON with the server's status —
  this is what Docker uses later to check if the container is "healthy"

`package.json` lists Express as the one dependency the app needs.

### 5. Wrote the Dockerfile
The Dockerfile is a recipe Docker follows to package the app into an image.
Key ideas, explained simply:
- **Multi-stage build** — dependencies are installed in one temporary stage,
  then only the finished result is copied into the final image. Keeps the
  image smaller and cleaner.
- **Runs as a non-root user** — safer than running as an administrator inside
  the container.
- **HEALTHCHECK** — a command Docker runs every 30 seconds to confirm the app
  is actually responding, by pinging `/healthz`.

### 6. Added a `.dockerignore`
Tells Docker not to copy things like `node_modules` and `.git` into the image
build — keeps builds faster and images smaller.

### 7. Built the Docker image
```bash
docker build -t codealpha-webserver:1.0 .
```
> Note: Docker Desktop has to be **open and running** in the background before
> this works, or you'll get a connection error.

### 8. Ran the container
```bash
docker run -d --name webserver -p 8080:3000 codealpha-webserver:1.0
```
- `-d` runs it in the background
- `--name webserver` gives the container a friendly name
- `-p 8080:3000` connects port 8080 on your computer to port 3000 inside the
  container (that's the port the app listens on)

### 9. Checked it worked
```bash
docker ps
```
Look at the `STATUS` column — after about 10 seconds it should say
`Up ... (healthy)`. That confirms the HEALTHCHECK is passing.

Then opened a browser to:
```
http://localhost:8080
```
and saw the page with a live Host ID, uptime, and a green status dot.

## Useful commands (container lifecycle)

```bash
docker ps                      # see running containers
docker ps -a                   # see all containers, including stopped ones
docker logs webserver          # view the app's output
docker stop webserver          # stop the container
docker start webserver         # start it again
docker restart webserver
docker exec -it webserver sh   # open a shell inside the running container
docker inspect webserver       # see full details about the container
docker rm -f webserver         # remove the container completely
```

## Running with Docker Compose instead

Instead of typing the long `docker run` command, this does the same thing in
one line:
```bash
docker compose up -d --build
```
And to stop everything:
```bash
docker compose down
```

## Try it yourself

```bash
git clone https://github.com/<your-username>/CodeAlpha_DockerWebServer.git
cd CodeAlpha_DockerWebServer
docker build -t codealpha-webserver:1.0 .
docker run -d --name webserver -p 8080:3000 codealpha-webserver:1.0
```
Then visit `http://localhost:8080`.

---

Submitted for the CodeAlpha DevOps Internship — Task 4.
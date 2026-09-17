const express = require("express");
const os = require("os");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const STARTED_AT = Date.now();

app.use(express.static(path.join(__dirname, "public")));

// Machine-readable status. The Docker HEALTHCHECK polls this endpoint,
// and the landing page uses it to show which container answered.
app.get("/healthz", (req, res) => {
  res.json({
    status: "ok",
    hostname: os.hostname(),
    uptimeSeconds: Math.floor((Date.now() - STARTED_AT) / 1000),
    nodeVersion: process.version,
    environment: process.env.NODE_ENV || "development",
  });
});

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`Listening on port ${PORT} as ${os.hostname()}`);
});

// Without this, Docker waits out its full timeout on every `docker stop`
// before killing the process. Handling SIGTERM makes shutdown immediate.
const shutdown = (signal) => {
  console.log(`${signal} received, closing server`);
  server.close(() => process.exit(0));
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

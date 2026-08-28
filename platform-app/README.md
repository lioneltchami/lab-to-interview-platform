# Signalboard

Signalboard is the original synthetic status-and-incident tracker used by the Lab to Interview platform. It is intentionally small: one Node.js HTTP service, deterministic synthetic data, a read-only responsive interface, health endpoints, structured logs, and no database or credentials.

## Local development

Use Node.js 22 from this directory:

```sh
npm test
APP_VERSION=0.1.0-local npm start
```

Then open `http://127.0.0.1:8080/` in a local browser, or validate the API:

```sh
curl --fail http://127.0.0.1:8080/health/live
curl --fail http://127.0.0.1:8080/health/ready
curl --fail http://127.0.0.1:8080/api/v1/version
curl --fail http://127.0.0.1:8080/api/v1/status
curl --fail http://127.0.0.1:8080/api/v1/incidents
```

Use `Ctrl+C` to stop the local process. The service does not write data to disk.

## API contract

| Endpoint | Purpose | Expected first-release response |
|---|---|---|
| `GET /` | Read-only responsive status interface. | HTML showing three synthetic components and one synthetic incident. |
| `GET /health/live` | Liveness probe. | `200` with `{ "status": "alive" }`. |
| `GET /health/ready` | Readiness probe. | `200` with a synthetic-data check. |
| `GET /api/v1/version` | Deployment identity endpoint. | `200` with service name and `APP_VERSION`. |
| `GET /api/v1/status` | Synthetic component status. | `200` with a timestamp, three components, and an overall state. |
| `GET /api/v1/incidents` | Synthetic incident timeline. | `200` with one non-sensitive incident record. |
| Any other route | Safe missing-route behavior. | `404` with a machine-readable error code. |

Only `GET` is supported in this release. Other methods return `405` and do not alter state.

## Container verification

Build and run the local ARM-compatible image:

```sh
docker build --tag signalboard:0.1.0-dev .
docker run --rm --publish 8080:8080 --env APP_VERSION=0.1.0-dev signalboard:0.1.0-dev
```

In a second terminal, validate the version and health endpoints. Stop the container with `Ctrl+C`. The deployment runbook later loads this local image into Kind; it does not publish an application image or expose an external endpoint during Phase 2.

## Runtime and data boundary

The service runs as the unprivileged `node` user inside the image. It receives only `PORT` and `APP_VERSION` in Phase 2. It uses deterministic synthetic data and must not receive real incident data, personal data, credentials, private cluster information, or host-mounted files.

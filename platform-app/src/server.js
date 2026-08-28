import http from 'node:http';
import { randomUUID } from 'node:crypto';
import { getIncidents, getStatus, serviceName } from './domain.js';

const defaultPort = Number.parseInt(process.env.PORT ?? '8080', 10);
const defaultVersion = process.env.APP_VERSION ?? 'dev';
const maxRequestIdLength = 128;

function safeRequestId(value) {
  if (typeof value === 'string' && /^[A-Za-z0-9._-]+$/.test(value) && value.length <= maxRequestIdLength) {
    return value;
  }

  return randomUUID();
}

function setCommonHeaders(response, requestId) {
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.setHeader('X-Frame-Options', 'DENY');
  response.setHeader('Referrer-Policy', 'no-referrer');
  response.setHeader('X-Request-Id', requestId);
}

function sendJson(response, statusCode, payload, requestId) {
  setCommonHeaders(response, requestId);
  response.statusCode = statusCode;
  response.end(`${JSON.stringify(payload)}\n`);
}

function sendHtml(response, html, requestId) {
  response.setHeader('Content-Type', 'text/html; charset=utf-8');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('Content-Security-Policy', "default-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'");
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.setHeader('X-Frame-Options', 'DENY');
  response.setHeader('Referrer-Policy', 'no-referrer');
  response.setHeader('X-Request-Id', requestId);
  response.statusCode = 200;
  response.end(html);
}

function statusClass(state) {
  if (state === 'operational') return 'ok';
  if (state === 'degraded') return 'warn';
  return 'neutral';
}

function renderPage({ status, incidents, version }) {
  const components = status.components
    .map((component) => `
      <article class="component">
        <div>
          <p class="eyebrow">${component.state}</p>
          <h3>${component.name}</h3>
          <p>${component.summary}</p>
        </div>
        <span class="state ${statusClass(component.state)}">${component.state}</span>
      </article>`)
    .join('');

  const incidentCards = incidents
    .map((incident) => `
      <article class="incident">
        <div class="incident-head">
          <div>
            <p class="eyebrow">${incident.impact} impact · ${incident.state}</p>
            <h3>${incident.title}</h3>
          </div>
          <span class="state ${statusClass(incident.state === 'monitoring' ? 'degraded' : incident.state)}">${incident.state}</span>
        </div>
        <ol>
          ${incident.updates
            .map((update) => `<li><time datetime="${update.at}">${new Date(update.at).toUTCString()}</time><p>${update.message}</p></li>`)
            .join('')}
        </ol>
      </article>`)
    .join('');

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Signalboard is a synthetic service-status workload for the Lab to Interview platform.">
  <title>Signalboard · Service status</title>
  <style>
    :root { color-scheme: dark; --ink: #edf3f4; --muted: #a7b6ba; --panel: #162126; --panel-2: #1c2a30; --line: #31434a; --accent: #76e0b1; --amber: #ffd36b; --canvas: #0d1417; }
    * { box-sizing: border-box; }
    body { margin: 0; background: radial-gradient(circle at 90% 0, #1f4141 0, transparent 32rem), var(--canvas); color: var(--ink); font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
    main { width: min(1080px, calc(100% - 2rem)); margin: 0 auto; padding: 3.5rem 0 5rem; }
    header { display: flex; align-items: flex-start; justify-content: space-between; gap: 2rem; padding-bottom: 2.5rem; border-bottom: 1px solid var(--line); }
    h1, h2, h3, p { margin-top: 0; } h1 { margin-bottom: .6rem; letter-spacing: -.04em; font-size: clamp(2.2rem, 7vw, 4.2rem); } h2 { margin-bottom: 1.25rem; font-size: 1.25rem; } h3 { margin-bottom: .45rem; font-size: 1.05rem; } p { color: var(--muted); line-height: 1.55; }
    .eyebrow { margin-bottom: .35rem; color: var(--accent); font-size: .72rem; font-weight: 760; letter-spacing: .12em; text-transform: uppercase; }
    .overview { max-width: 43rem; margin-bottom: 0; font-size: 1.05rem; }
    .state { flex: 0 0 auto; border: 1px solid var(--line); border-radius: 999px; padding: .35rem .62rem; color: var(--muted); font-size: .78rem; font-weight: 700; text-transform: capitalize; }
    .state.ok { border-color: color-mix(in srgb, var(--accent), transparent 45%); color: var(--accent); } .state.warn { border-color: color-mix(in srgb, var(--amber), transparent 40%); color: var(--amber); }
    section { margin-top: 2.8rem; } .grid { display: grid; gap: 1rem; grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .component, .incident { border: 1px solid var(--line); background: color-mix(in srgb, var(--panel), transparent 8%); border-radius: 1rem; padding: 1.25rem; }
    .component { display: flex; flex-direction: column; justify-content: space-between; min-height: 12rem; gap: 1rem; } .component .state { align-self: flex-start; }
    .incident-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem; } ol { margin: 1.4rem 0 0; padding: 0; list-style: none; } li { border-top: 1px solid var(--line); padding: 1rem 0 0; margin-top: 1rem; } time { color: var(--muted); font-size: .82rem; } li p { margin: .35rem 0 0; }
    .footnote { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; color: var(--muted); font-size: .84rem; }
    @media (max-width: 720px) { main { padding-top: 2rem; } header { flex-direction: column; gap: 1rem; } .grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
  <main>
    <header>
      <div>
        <p class="eyebrow">Lab to Interview · synthetic workload</p>
        <h1>${serviceName}</h1>
        <p class="overview">${status.overallState === 'operational' ? 'All synthetic learning services are operating normally.' : 'A synthetic learning service is experiencing a non-critical delay.'}</p>
      </div>
      <span class="state ${statusClass(status.overallState)}">${status.overallState}</span>
    </header>
    <section aria-labelledby="components-heading">
      <h2 id="components-heading">Components</h2>
      <div class="grid">${components}</div>
    </section>
    <section aria-labelledby="incidents-heading">
      <h2 id="incidents-heading">Recent incident</h2>
      ${incidentCards}
    </section>
    <section class="footnote" aria-label="Service metadata">
      <span>Generated at ${new Date(status.generatedAt).toUTCString()}</span>
      <span>Release ${version}</span>
    </section>
  </main>
</body>
</html>`;
}

function logRequest(logger, fields) {
  logger.info(JSON.stringify({ event: 'http_request', ...fields }));
}

export function createServer({ logger = console, version = defaultVersion } = {}) {
  return http.createServer((request, response) => {
    const startedAt = process.hrtime.bigint();
    const requestId = safeRequestId(request.headers['x-request-id']);
    const url = new URL(request.url ?? '/', 'http://signalboard.local');
    const path = url.pathname;

    response.on('finish', () => {
      const durationMs = Number(process.hrtime.bigint() - startedAt) / 1_000_000;
      logRequest(logger, {
        requestId,
        method: request.method,
        path,
        statusCode: response.statusCode,
        durationMs: Number(durationMs.toFixed(2))
      });
    });

    try {
      if (request.method !== 'GET') {
        sendJson(response, 405, { error: { code: 'method_not_allowed', message: 'Only GET requests are supported in this release.' } }, requestId);
        return;
      }

      if (path === '/health/live') {
        sendJson(response, 200, { status: 'alive' }, requestId);
        return;
      }

      if (path === '/health/ready') {
        sendJson(response, 200, { status: 'ready', checks: { syntheticData: 'ready' } }, requestId);
        return;
      }

      if (path === '/api/v1/version') {
        sendJson(response, 200, { service: serviceName, version }, requestId);
        return;
      }

      if (path === '/api/v1/status') {
        sendJson(response, 200, getStatus(), requestId);
        return;
      }

      if (path === '/api/v1/incidents') {
        sendJson(response, 200, { incidents: getIncidents() }, requestId);
        return;
      }

      if (path === '/') {
        sendHtml(response, renderPage({ status: getStatus(), incidents: getIncidents(), version }), requestId);
        return;
      }

      sendJson(response, 404, { error: { code: 'route_not_found', message: 'The requested resource does not exist.' } }, requestId);
    } catch (error) {
      logger.error(JSON.stringify({ event: 'http_request_error', requestId, path, message: error instanceof Error ? error.message : 'unknown_error' }));
      sendJson(response, 500, { error: { code: 'internal_error', message: 'Signalboard could not process the request.' } }, requestId);
    }
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const server = createServer();
  server.listen(defaultPort, '0.0.0.0', () => {
    console.info(JSON.stringify({ event: 'server_started', service: serviceName, version: defaultVersion, port: defaultPort }));
  });
}

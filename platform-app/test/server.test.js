import assert from 'node:assert/strict';
import test from 'node:test';
import { createServer } from '../src/server.js';

async function startServer(t, options = {}) {
  const server = createServer(options);
  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });

  t.after(async () => {
    await new Promise((resolve) => server.close(resolve));
  });

  const address = server.address();
  return {
    request(path, options = {}) {
      return fetch(`http://127.0.0.1:${address.port}${path}`, options);
    }
  };
}

test('status endpoint reports the deterministic synthetic component state', async (t) => {
  const app = await startServer(t);
  const response = await app.request('/api/v1/status', { headers: { 'x-request-id': 'test-request-42' } });
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(response.headers.get('x-request-id'), 'test-request-42');
  assert.equal(response.headers.get('cache-control'), 'no-store');
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff');
  assert.equal(body.service, 'Signalboard');
  assert.equal(body.overallState, 'degraded');
  assert.equal(body.activeIncidentCount, 1);
  assert.deepEqual(body.release, { dataMode: 'synthetic', marker: 'phase-two-foundation' });
  assert.equal(body.components.length, 3);
  assert.deepEqual(body.components.map((component) => component.id), ['enrollment-api', 'learning-library', 'evidence-index']);
  assert.match(body.generatedAt, /^\d{4}-\d{2}-\d{2}T/);
});

test('health and version endpoints return distinct operational contracts', async (t) => {
  const app = await startServer(t, { version: '0.1.0-test' });
  const [liveResponse, readyResponse, versionResponse] = await Promise.all([
    app.request('/health/live'),
    app.request('/health/ready'),
    app.request('/api/v1/version')
  ]);

  assert.deepEqual(await liveResponse.json(), { status: 'alive' });
  assert.deepEqual(await readyResponse.json(), { status: 'ready', checks: { syntheticData: 'ready' } });
  assert.deepEqual(await versionResponse.json(), { service: 'Signalboard', version: '0.1.0-test' });
});

test('unknown routes and unsupported methods fail with clear safe responses', async (t) => {
  const app = await startServer(t);
  const [missingResponse, methodResponse] = await Promise.all([
    app.request('/api/v1/does-not-exist'),
    app.request('/api/v1/status', { method: 'POST' })
  ]);

  assert.equal(missingResponse.status, 404);
  assert.deepEqual(await missingResponse.json(), {
    error: { code: 'route_not_found', message: 'The requested resource does not exist.' }
  });
  assert.equal(methodResponse.status, 405);
  assert.deepEqual(await methodResponse.json(), {
    error: { code: 'method_not_allowed', message: 'Only GET requests are supported in this release.' }
  });
});

test('root interface renders synthetic status information', async (t) => {
  const app = await startServer(t, { version: '0.1.0-test' });
  const response = await app.request('/');
  const html = await response.text();

  assert.equal(response.status, 200);
  assert.match(response.headers.get('content-security-policy'), /default-src 'self'/);
  assert.match(html, /<title>Signalboard · Service status<\/title>/);
  assert.match(html, /Enrollment API/);
  assert.match(html, /Evidence Index refresh delay/);
  assert.match(html, /Release 0\.1\.0-test/);
});

test('structured request logs exclude query content and preserve a generated request identifier', async (t) => {
  const messages = [];
  const app = await startServer(t, { logger: { info: (message) => messages.push(message), error: () => {} } });
  const response = await app.request('/api/v1/status?private-value=do-not-log');
  await response.text();

  assert.equal(messages.length, 1);
  const entry = JSON.parse(messages[0]);
  assert.equal(entry.event, 'http_request');
  assert.equal(entry.path, '/api/v1/status');
  assert.equal(entry.statusCode, 200);
  assert.match(entry.requestId, /^[0-9a-f-]{36}$/);
  assert.equal('query' in entry, false);
});

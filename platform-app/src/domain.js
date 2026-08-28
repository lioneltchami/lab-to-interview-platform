export const serviceName = 'Signalboard';

const components = [
  {
    id: 'enrollment-api',
    name: 'Enrollment API',
    state: 'operational',
    summary: 'Accepting synthetic course-enrollment requests.'
  },
  {
    id: 'learning-library',
    name: 'Learning Library',
    state: 'operational',
    summary: 'Serving original lab guides and evidence references.'
  },
  {
    id: 'evidence-index',
    name: 'Evidence Index',
    state: 'degraded',
    summary: 'Refreshing a simulated report view more slowly than expected.'
  }
];

const incidents = [
  {
    id: 'inc-2026-001',
    title: 'Evidence Index refresh delay',
    state: 'monitoring',
    impact: 'minor',
    startedAt: '2026-08-20T09:15:00.000Z',
    updatedAt: '2026-08-20T10:05:00.000Z',
    affectedComponentIds: ['evidence-index'],
    updates: [
      {
        at: '2026-08-20T09:15:00.000Z',
        state: 'investigating',
        message: 'A synthetic refresh delay was detected during a scheduled demonstration.'
      },
      {
        at: '2026-08-20T09:40:00.000Z',
        state: 'identified',
        message: 'The simulated source is responding slowly; learner-facing data remains available.'
      },
      {
        at: '2026-08-20T10:05:00.000Z',
        state: 'monitoring',
        message: 'The refresh delay has improved and the service remains under observation.'
      }
    ]
  }
];

export function getComponents() {
  return components.map((component) => ({ ...component }));
}

export function getIncidents() {
  return incidents.map((incident) => ({
    ...incident,
    affectedComponentIds: [...incident.affectedComponentIds],
    updates: incident.updates.map((update) => ({ ...update }))
  }));
}

export function getStatus() {
  const currentComponents = getComponents();
  const currentIncidents = getIncidents();
  const degradedComponents = currentComponents.filter((component) => component.state !== 'operational');

  return {
    service: serviceName,
    overallState: degradedComponents.length === 0 ? 'operational' : 'degraded',
    generatedAt: new Date().toISOString(),
    activeIncidentCount: currentIncidents.filter((incident) => incident.state !== 'resolved').length,
    components: currentComponents
  };
}

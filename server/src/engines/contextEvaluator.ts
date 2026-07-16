import type { AccessRequest, DenyReason } from '../../../shared/types.js';
import { getActivePeriod, getSystemState, listContextPolicies } from '../data/repository.js';

function matchesIpRanges(ip: string, ranges: string[]): boolean {
  if (!ip || ip === '::1' || ip === '127.0.0.1' || ip === '::ffff:127.0.0.1' || ip.startsWith('localhost')) {
    return true;
  }
  return ranges.some((range) => {
    if (range.endsWith('/8')) {
      const prefix = `${range.split('.')[0]}.`;
      return ip.startsWith(prefix);
    }
    if (range.endsWith('/24')) {
      const parts = range.split('.').slice(0, 3).join('.');
      return ip.startsWith(parts);
    }
    return ip === range;
  });
}

export async function evaluateContext(request: AccessRequest): Promise<{ passed: boolean; denyReason?: DenyReason; reason?: string }> {
  const systemState = await getSystemState();
  if (systemState.emergency_lockout_active) {
    return { passed: false, denyReason: 'RESOURCE_NOT_FOUND', reason: 'Emergency system lockout active' };
  }

  const envPolicy = systemState.policy_config.environmental;
  if (envPolicy.ipRanges && envPolicy.ipRanges.length > 0) {
    const ip = request.context.ipAddress;
    if (!matchesIpRanges(ip, envPolicy.ipRanges)) {
      return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: 'Access denied: client IP outside permitted range' };
    }
  }

  if (
    envPolicy.timeWindow &&
    envPolicy.timeWindow.blockOutside &&
    request.resource === 'grades' &&
    ['write', 'submit', 'approve', 'modify'].includes(request.action)
  ) {
    const now = request.context.timestamp;
    const [startH, startM] = envPolicy.timeWindow.start.split(':').map(Number);
    const [endH, endM] = envPolicy.timeWindow.end.split(':').map(Number);
    const currentMins = now.getHours() * 60 + now.getMinutes();
    const startMins = startH * 60 + (startM || 0);
    const endMins = endH * 60 + (endM || 0);
    if (currentMins < startMins || currentMins > endMins) {
      return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: 'Access denied: outside allowed academic hours (08:00 - 18:00)' };
    }
  }

  if (request.resource === 'grades' && ['write', 'submit', 'modify'].includes(request.action)) {
    const current = await getActivePeriod();
    if (!current) {
      return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: 'No active academic period' };
    }
    const now = request.context.timestamp;
    const open = new Date(current.gradingOpen).getTime();
    const close = new Date(current.gradingClose).getTime();
    if (now.getTime() < open || now.getTime() > close) {
      return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: 'Grading window is closed' };
    }
  }

  const policies = await listContextPolicies();
  for (const policy of policies.filter((item) => item.isActive && item.resource === request.resource && item.action === request.action)) {
    const condition = policy.condition as Record<string, unknown>;
    if (typeof condition.requiresActivePeriod === 'boolean' && condition.requiresActivePeriod) {
      if (!(await getActivePeriod())) {
        return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: `${policy.name} requires active period` };
      }
    }
    if (Array.isArray(condition.allowedHours)) {
      const hours = condition.allowedHours as [number, number];
      const hour = request.context.timestamp.getUTCHours();
      if (hour < hours[0] || hour > hours[1]) {
        return { passed: false, denyReason: 'OUTSIDE_GRADING_PERIOD', reason: `${policy.name} hour restriction failed` };
      }
    }
  }

  return { passed: true };
}


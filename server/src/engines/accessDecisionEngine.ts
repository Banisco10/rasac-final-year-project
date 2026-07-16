import type { AccessRequest, AccessDecision } from '../../../shared/types.js';
import { createSeparationOfDutyLog } from '../data/repository.js';
import { auditLogger } from '../utils/auditLogger.js';
import { validateRole } from './roleValidator.js';
import { validateRelationship } from './relationshipValidator.js';
import { evaluateContext } from './contextEvaluator.js';
import { checkSeparationOfDuty } from './separationOfDuty.js';


type DecisionTraceStep = {
  layer: 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD';
  result: 'PASS' | 'FAIL';
  reason?: string;
  durationMs?: number;
};

type TracedDecision = AccessDecision & {
  trace: DecisionTraceStep[];
};

export class AccessDecisionEngine {
  async evaluate(request: AccessRequest): Promise<TracedDecision> {
  const start = Date.now();
  const trace: DecisionTraceStep[] = [];

  const roleStart = Date.now();
  const roleCheck = await validateRole(request);

  trace.push({
    layer: 'ROLE',
    result: roleCheck.passed ? 'PASS' : 'FAIL',
    reason: roleCheck.passed ? undefined : 'INSUFFICIENT_ROLE',
    durationMs: Date.now() - roleStart,
  });

  if (!roleCheck.passed) {
    await auditLogger.log({
      userId: request.userId,
      action: request.action,
      resource: request.resource,
      resourceId: request.resourceId ?? null,
      outcome: 'DENIED_ROLE',
      denyReason: 'INSUFFICIENT_ROLE',
      ipAddress: request.context.ipAddress,
      metadata: { layer: 'ROLE' },
    });

    return {
      granted: false,
      outcome: 'DENIED_ROLE',
      denyReason: 'INSUFFICIENT_ROLE',
      layerFailed: 'ROLE',
      evaluationMs: Date.now() - start,
      trace,
    };
  }

  const relStart = Date.now();
  const relationshipCheck = await validateRelationship(request);

  trace.push({
    layer: 'RELATIONSHIP',
    result: relationshipCheck.passed ? 'PASS' : 'FAIL',
    reason: relationshipCheck.passed ? undefined : 'NO_ACADEMIC_RELATIONSHIP',
    durationMs: Date.now() - relStart,
  });

  if (!relationshipCheck.passed) {
    await auditLogger.log({
      userId: request.userId,
      action: request.action,
      resource: request.resource,
      resourceId: request.resourceId ?? null,
      outcome: 'DENIED_RELATIONSHIP',
      denyReason: 'NO_ACADEMIC_RELATIONSHIP',
      ipAddress: request.context.ipAddress,
      metadata: { layer: 'RELATIONSHIP' },
    });

    return {
      granted: false,
      outcome: 'DENIED_RELATIONSHIP',
      denyReason: 'NO_ACADEMIC_RELATIONSHIP',
      layerFailed: 'RELATIONSHIP',
      evaluationMs: Date.now() - start,
      trace,
    };
  }


  const ctxStart = Date.now();
  const contextCheck = await evaluateContext(request);

  trace.push({
    layer: 'CONTEXT',
    result: contextCheck.passed ? 'PASS' : 'FAIL',
    reason: contextCheck.passed ? undefined : contextCheck.denyReason ?? 'OUTSIDE_GRADING_PERIOD',
    durationMs: Date.now() - ctxStart,
  });

  if (!contextCheck.passed) {
    await auditLogger.log({
      userId: request.userId,
      action: request.action,
      resource: request.resource,
      resourceId: request.resourceId ?? null,
      outcome: 'DENIED_CONTEXT',
      denyReason: contextCheck.denyReason ?? 'OUTSIDE_GRADING_PERIOD',
      ipAddress: request.context.ipAddress,
      metadata: { layer: 'CONTEXT' },
    });

    return {
      granted: false,
      outcome: 'DENIED_CONTEXT',
      denyReason: contextCheck.denyReason ?? 'OUTSIDE_GRADING_PERIOD',
      layerFailed: 'CONTEXT',
      evaluationMs: Date.now() - start,
      trace,
    };
  }


  const sodStart = Date.now();
  const sodCheck = await checkSeparationOfDuty(request);

  trace.push({
    layer: 'SOD',
    result: sodCheck.passed ? 'PASS' : 'FAIL',
    reason: sodCheck.passed ? undefined : sodCheck.reason ?? 'SEPARATION_OF_DUTY_VIOLATION',
    durationMs: Date.now() - sodStart,
  });

  if (!sodCheck.passed) {
    await createSeparationOfDutyLog({
      userId: request.userId,
      violation: sodCheck.reason ?? 'Separation of duty violation',
      attempted: `${request.resource}:${request.action}`,
      blocked: true,
    });

    await auditLogger.log({
      userId: request.userId,
      action: request.action,
      resource: request.resource,
      resourceId: request.resourceId ?? null,
      outcome: 'DENIED_SOD',
      denyReason: 'SEPARATION_OF_DUTY_VIOLATION',
      ipAddress: request.context.ipAddress,
      metadata: { layer: 'SOD' },
    });

    return {
      granted: false,
      outcome: 'DENIED_SOD',
      denyReason: 'SEPARATION_OF_DUTY_VIOLATION',
      layerFailed: 'SOD',
      evaluationMs: Date.now() - start,
      trace,
    };
  }


  await auditLogger.log({
    userId: request.userId,
    action: request.action,
    resource: request.resource,
    resourceId: request.resourceId ?? null,
    outcome: 'GRANTED',
    ipAddress: request.context.ipAddress,
    metadata: { layer: 'ALL' },
  });

  return {
    granted: true,
    outcome: 'GRANTED',
    evaluationMs: Date.now() - start,
    trace,
  };
}
}

export const accessDecisionEngine = new AccessDecisionEngine();


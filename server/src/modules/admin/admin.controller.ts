import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import {
  countAuditByOutcome,
  countActiveCourses,
  countActiveSessions,
  countGradeSubmissions,
  getActivePeriod,
  getSystemState,
  listAuditLogs,
  listPendingGradesForAdmin,
  listPermissions,
  listRolePermissions,
  listRoles,
  listUsers,
  setEmergencyLockout,
  updatePolicyConfig,
} from '../../data/repository.js';
import { sendSuccess } from '../../utils/response.js';
import { auditLogger } from '../../utils/auditLogger.js';

export async function getAdminStats(req: AuthenticatedRequest, res: Response): Promise<void> {
  const users = await listUsers();
  const today = new Date().toISOString().slice(0, 10);
  const audits = await listAuditLogs();
  const state = await getSystemState();
  const activeSessions = await countActiveSessions();
  const denialsToday = audits.filter((log) => log.timestamp.startsWith(today) && log.outcome !== 'GRANTED');

  sendSuccess(res, {
    userCounts: {
      total: users.length,
      administrators: users.filter((user) => user.role === 'ADMINISTRATOR').length,
      lecturers: users.filter((user) => user.role === 'LECTURER').length,
      students: users.filter((user) => user.role === 'STUDENT').length,
    },
    activeSessions,
    denialsToday: {
      total: denialsToday.length,
      role: denialsToday.filter((log) => log.outcome === 'DENIED_ROLE').length,
      relationship: denialsToday.filter((log) => log.outcome === 'DENIED_RELATIONSHIP').length,
      context: denialsToday.filter((log) => log.outcome === 'DENIED_CONTEXT').length,
      sod: denialsToday.filter((log) => log.outcome === 'DENIED_SOD').length,
    },
    activeCourses: await countActiveCourses(),
    gradeSubmissions: await countGradeSubmissions(),
    securityEvents: audits.length,
    activePeriod: await getActivePeriod(),
    emergencyLockoutActive: state.emergency_lockout_active,
  });
}

export async function getSecurityEvents(req: AuthenticatedRequest, res: Response): Promise<void> {
  const audits = await listAuditLogs();
  sendSuccess(res, {
    ROLE: audits.filter((item) => item.outcome === 'DENIED_ROLE'),
    RELATIONSHIP: audits.filter((item) => item.outcome === 'DENIED_RELATIONSHIP'),
    CONTEXT: audits.filter((item) => item.outcome === 'DENIED_CONTEXT'),
    SOD: audits.filter((item) => item.outcome === 'DENIED_SOD'),
  });
}

export async function getAccessMatrix(req: AuthenticatedRequest, res: Response): Promise<void> {
  const state = await getSystemState();
  sendSuccess(res, {
    roles: await listRoles(),
    permissions: await listPermissions(),
    rolePermissions: await listRolePermissions(),
    policyConfig: state.policy_config,
    emergencyLockoutActive: state.emergency_lockout_active,
  });
}

export async function updateAccessMatrix(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { policyConfig } = req.body;
  if (policyConfig) {
    await updatePolicyConfig(policyConfig);
  }
  await auditLogger.log({
    userId: req.auth!.userId,
    action: 'write',
    resource: 'periods',
    resourceId: 'policy-config',
    outcome: 'GRANTED',
    ipAddress: req.ip ?? '',
    metadata: { layer: 'ALL', message: 'Global Access Control policy redeployed' },
  });
  const state = await getSystemState();
  sendSuccess(res, { success: true, policyConfig: state.policy_config });
}

export async function toggleEmergencyLockout(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { active } = req.body;
  await setEmergencyLockout(!!active);
  await auditLogger.log({
    userId: req.auth!.userId,
    action: active ? 'write' : 'read',
    resource: 'periods',
    resourceId: 'emergency-lockout',
    outcome: active ? 'DENIED_CONTEXT' : 'GRANTED',
    ipAddress: req.ip ?? '',
    metadata: { layer: 'CONTEXT', message: active ? 'System placed in emergency lockout' : 'Emergency lockout deactivated' },
  });
  const state = await getSystemState();
  sendSuccess(res, { success: true, emergencyLockoutActive: state.emergency_lockout_active });
}

export async function getGradeApprovalQueue(req: AuthenticatedRequest, res: Response): Promise<void> {
  const queue = await listPendingGradesForAdmin();
  sendSuccess(res, { data: queue, total: queue.length });
}
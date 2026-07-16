import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { auditStats, countAuditByOutcome, listAuditLogs, listMyAuditLogs } from '../../data/repository.js';
import { sendSuccess } from '../../utils/response.js';

export async function getAllAuditLogs(req: AuthenticatedRequest, res: Response): Promise<void> {
  const logs = await listAuditLogs();
  sendSuccess(res, {
    data: logs,
    total: logs.length,
    page: 1,
    totalPages: 1,
  });
}

export async function getAuditStats(req: AuthenticatedRequest, res: Response): Promise<void> {
  const stats = await auditStats();
  sendSuccess(res, {
    outcomes: stats,
    denyCounts: {
      role: await countAuditByOutcome('DENIED_ROLE'),
      relationship: await countAuditByOutcome('DENIED_RELATIONSHIP'),
      context: await countAuditByOutcome('DENIED_CONTEXT'),
      sod: await countAuditByOutcome('DENIED_SOD'),
    },
  });
}

export async function getUserAuditLogs(req: AuthenticatedRequest, res: Response): Promise<void> {
  const userId = Number(req.params.userId);
  sendSuccess(res, await listMyAuditLogs(userId));
}

export async function getMyAuditLogs(req: AuthenticatedRequest, res: Response): Promise<void> {
  sendSuccess(res, await listMyAuditLogs(req.auth!.userId));
}


import type { AuditLog, AuditOutcome, DenyReason } from '../../../shared/types.js';
import { createAuditLog } from '../data/repository.js';

export interface AuditEntry {
  userId?: number | null;
  action: string;
  resource: string;
  resourceId?: string | null;
  outcome: AuditOutcome;
  denyReason?: DenyReason | null;
  ipAddress?: string | null;
  userAgent?: string | null;
  requestPath?: string | null;
  metadata?: Record<string, unknown> | null;
}

export const auditLogger = {
  async log(entry: AuditEntry): Promise<AuditLog> {
    return createAuditLog({
      userId: entry.userId ?? null,
      action: entry.action,
      resource: entry.resource,
      resourceId: entry.resourceId ?? null,
      outcome: entry.outcome,
      denyReason: entry.denyReason ?? null,
      ipAddress: entry.ipAddress ?? null,
      userAgent: entry.userAgent ?? null,
      requestPath: entry.requestPath ?? null,
      metadata: entry.metadata ?? null,
    });
  },
};


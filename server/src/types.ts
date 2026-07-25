import type { Request } from "express";

export type RoleCode = "ADMINISTRATOR" | "LECTURER" | "STUDENT";

export type AuthUser = {
  id: number;
  email: string;
  fullName: string;
  roles: RoleCode[];
};

export type AuthenticatedRequest = Request & {
  user?: AuthUser;
};

export type AuditOutcome = "ALLOW" | "DENY" | "ERROR";

export type DenyReason =
  | "INSUFFICIENT_ROLE"
  | "NO_ACADEMIC_RELATIONSHIP"
  | "OUTSIDE_GRADING_PERIOD"
  | "SEPARATION_OF_DUTY_VIOLATION"
  | "ACCOUNT_LOCKED"
  | "SESSION_EXPIRED"
  | "RESOURCE_NOT_FOUND";

export type AccessContext = {
  timestamp: Date;
  ipAddress: string;
  academicPeriodId?: number;
  targetStudentId?: number;
  targetCourseId?: number;
  requestPath?: string;
};

export type AccessRequest = {
  userId: number;
  userRoles: RoleCode[];
  resource: string;
  action: string;
  resourceId?: string;
  context: AccessContext;
};

export type AccessDecision = {
  granted: boolean;
  outcome: AuditOutcome;
  denyReason?: DenyReason;
  layerFailed?: "ROLE" | "RELATIONSHIP" | "CONTEXT" | "SOD";
  evaluationMs: number;
};

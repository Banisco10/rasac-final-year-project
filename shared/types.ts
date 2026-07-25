export type RoleName = 'ADMINISTRATOR' | 'LECTURER' | 'STUDENT';

export type AuditOutcome =
  | 'GRANTED'
  | 'DENIED_ROLE'
  | 'DENIED_RELATIONSHIP'
  | 'DENIED_CONTEXT'
  | 'DENIED_SOD'
  | 'ERROR';

export type DenyReason =
  | 'INSUFFICIENT_ROLE'
  | 'NO_ACADEMIC_RELATIONSHIP'
  | 'OUTSIDE_GRADING_PERIOD'
  | 'SEPARATION_OF_DUTY_VIOLATION'
  | 'ACCOUNT_LOCKED'
  | 'SESSION_EXPIRED'
  | 'RESOURCE_NOT_FOUND';

export type GradeStatus = 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED';
export type EnrollmentStatus = 'ACTIVE' | 'DROPPED' | 'COMPLETED';

export interface Role {
  id: number;
  name: RoleName;
  description?: string | null;
}

export interface Permission {
  id: number;
  resource: string;
  action: string;
  description?: string | null;
}

export interface User {
  id: number;
  studentId?: string | null;
  staffId?: string | null;
  firstName: string;
  lastName: string;
  email: string;
  passwordHash: string;
  roleId: number;
  department?: string | null;
  officeLocation?: string | null;
  consultationHours?: string | null;
  isActive: boolean;
  failedLogins: number;
  lockedUntil?: string | null;
  lastLogin?: string | null;
  lastLoginIp?: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface Session {
  id: string;
  userId: number;
  refreshToken: string;
  ipAddress?: string | null;
  userAgent?: string | null;
  isRevoked: boolean;
  expiresAt: string;
  createdAt: string;
}

export interface PreviousLoginInfo {
  lastLogin: string | null;
  ipAddress: string | null;
}

export interface Department {
  id: number;
  name: string;
  code: string;
  createdAt: string;
}

export interface AcademicPeriod {
  id: number;
  name: string;
  startDate: string;
  endDate: string;
  gradingOpen: string;
  gradingClose: string;
  isActive: boolean;
  createdAt: string;
}

export interface Course {
  id: number;
  code: string;
  title: string;
  credits: number;
  departmentId: number;
  lecturerId: number;
  academicPeriodId: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Enrollment {
  id: number;
  studentId: number;
  courseId: number;
  enrolledAt: string;
  status?: EnrollmentStatus;
}

export interface Grade {
  id: number;
  studentId: number;
  courseId: number;
  submitterId: number;
  approverId?: number | null;
  score: number;
  grade: string;
  remarks?: string | null;
  status: GradeStatus;
  submittedAt: string;
  approvedAt?: string | null;
}

export interface AuditLog {
  id: number;
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
  timestamp: string;
}

export interface SeparationOfDutyLog {
  id: number;
  userId: number;
  violation: string;
  attempted: string;
  blocked: boolean;
  timestamp: string;
}

export interface ContextPolicy {
  id: number;
  name: string;
  description: string;
  resource: string;
  action: string;
  condition: Record<string, unknown>;
  isActive: boolean;
  createdAt: string;
}

export interface AccessContext {
  timestamp: Date;
  ipAddress: string;
  academicPeriodId?: number;
  targetStudentId?: number;
  targetCourseId?: number;
  requestPath?: string;
}

export interface AccessRequest {
  userId: number;
  userRole: RoleName;
  resource: string;
  action: string;
  resourceId?: string;
  context: AccessContext;
}

export interface AccessDecision {
  granted: boolean;
  reason?: string;
  outcome: AuditOutcome;
  denyReason?: DenyReason;
  layerFailed?: 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD';
  evaluationMs: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  code?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  totalPages: number;
}

export interface AuthenticatedUser {
  id: number;
  fullName: string;
  email: string;
  role: RoleName;
  permissions: Array<{ resource: string; action: string }>;
  department?: string | null;
  officeLocation?: string | null;
  consultationHours?: string | null;
  studentId?: string | null;
  staffId?: string | null;
  lastLogin?: string | null;
}

export interface PolicyConfig {
  matrix: Record<RoleName, { read: boolean; write: boolean; delete: boolean; approve: boolean }>;
  associations: {
    enrolledInCourse: { strengthThreshold: number; timeoutMins: number; isActive: boolean };
    assignedLecturer: { verificationDepth: string; reauthCycle: string; isActive: boolean };
  };
  environmental: {
    ipRanges: string[];
    timeWindow: { start: string; end: string; blockOutside: boolean };
    gradingPeriod: { requiredPeriod: string; daysLeft: number };
  };
}

export interface DecisionTraceStep {
  layer: 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD';
  result: 'PASS' | 'FAIL';
  reason?: string;
  durationMs?: number;
}

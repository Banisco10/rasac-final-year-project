import { ApiResponse, AcademicPeriod, AuditLog, AuthenticatedUser, Course, Enrollment, Grade, PreviousLoginInfo, PolicyConfig } from './types';

type AdminStats = {
  userCounts: {
    total: number;
    administrators: number;
    lecturers: number;
    students: number;
  };
  activeSessions: number;
  denialsToday: {
    total: number;
    role: number;
    relationship: number;
    context: number;
    sod: number;
  };
  activeCourses: number;
  gradeSubmissions: number;
  securityEvents: number;
  activePeriod: AcademicPeriod | null;
};

type UsersResponse = {
  data: Array<{
    id: number;
    fullName: string;
    email: string;
    role: string;
    isActive: boolean;
  }>;
  total: number;
  page: number;
  totalPages: number;
  viewerRole: string;
};

type SecurityEventsResponse = {
  ROLE: AuditLog[];
  RELATIONSHIP: AuditLog[];
  CONTEXT: AuditLog[];
  SOD: AuditLog[];
};

type CourseMembersResponse = {
  data: Array<{
    id: number;
    fullName: string;
    email: string;
    role: string;
    studentId?: string | null;
    staffId?: string | null;
    department?: string | null;
    isActive: boolean;
  }>;
  total: number;
  page: number;
  totalPages: number;
};

type TranscriptResponse = {
  studentId: number;
  gpa: number;
  totalCredits: number;
  grades: Array<Grade & { course: Course | null }>;
};

type GradeQueueItem = {
  id: number;
  studentId: number;
  studentName: string;
  courseId: number;
  courseCode: string;
  courseTitle: string;
  score: number;
  grade: string;
  submitterId: number;
  submitterName: string;
  status: string;
  sodRisk: boolean;
  submittedAt: string;
};
type AuditStatsResponse = {
  outcomes: Record<string, number>;
  denyCounts: { role: number; relationship: number; context: number; sod: number };
};

type AccessDecisionTraceStep = {
  layer: 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD';
  result: 'PASS' | 'FAIL';
  reason?: string;
  durationMs?: number;
};

type SimulatedAccessDecision = {
  granted: boolean;
  outcome: string;
  denyReason?: string;
  layerFailed?: 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD';
  evaluationMs: number;
  trace: AccessDecisionTraceStep[];
};

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:4000/api/v1';

const TOKEN_KEY = 'rasac_access_token';
const REMEMBER_KEY = 'rasac_remember';

let accessToken: string | null = localStorage.getItem(TOKEN_KEY) ?? sessionStorage.getItem(TOKEN_KEY);

export function setAccessToken(token: string | null, persist?: boolean): void {
  accessToken = token;
  if (token) {
    // If persist flag is provided, store the preference
    if (persist !== undefined) {
      if (persist) {
        localStorage.setItem(REMEMBER_KEY, '1');
      } else {
        localStorage.removeItem(REMEMBER_KEY);
      }
    }
    const shouldPersist = persist ?? localStorage.getItem(REMEMBER_KEY) === '1';
    if (shouldPersist) {
      localStorage.setItem(TOKEN_KEY, token);
      sessionStorage.removeItem(TOKEN_KEY);
    } else {
      sessionStorage.setItem(TOKEN_KEY, token);
      localStorage.removeItem(TOKEN_KEY);
    }
  } else {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REMEMBER_KEY);
    sessionStorage.removeItem(TOKEN_KEY);
  }
}

export function hasStoredToken(): boolean {
  return !!(localStorage.getItem(TOKEN_KEY) ?? sessionStorage.getItem(TOKEN_KEY));
}

export function getAccessToken(): string | null {
  return accessToken;
}

async function requestRaw<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = new Headers(init.headers);
  headers.set('Content-Type', 'application/json');
  if (accessToken) {
    headers.set('Authorization', `Bearer ${accessToken}`);
  }
  const response = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers,
    credentials: 'include',
  });
  const payload = await response.json() as ApiResponse<T> | { success?: boolean; data?: T; message?: string; code?: string };
  if (!response.ok || payload.success === false) {
    const error = new Error(payload.message ?? 'Request failed') as Error & { status?: number };
    error.status = response.status;
    throw error;
  }
  return (payload.data ?? payload) as T;
}

async function request<T>(path: string, init: RequestInit = {}, retried = false): Promise<T> {
  try {
    return await requestRaw<T>(path, init);
  } catch (error) {
    const status = error instanceof Error ? (error as Error & { status?: number }).status : undefined;
    const isAuthMutation =
      path.endsWith('/auth/login') ||
      path.endsWith('/auth/logout') ||
      path.endsWith('/auth/refresh') ||
      path.endsWith('/auth/change-password');
    if (retried || status !== 401 || !accessToken || isAuthMutation) {
      throw error;
    }
    const refreshResponse = await fetch(`${API_BASE}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: '{}',
    });
    const refreshPayload = await refreshResponse.json() as ApiResponse<{ accessToken: string }> | { success?: boolean; data?: { accessToken: string }; message?: string };
    if (!refreshResponse.ok || refreshPayload.success === false || !refreshPayload.data?.accessToken) {
      throw error;
    }
    setAccessToken(refreshPayload.data.accessToken);
    return request<T>(path, init, true);
  }
}

export const api = {
  async login(email: string, password: string, rememberMe = false) {
    return request<{ accessToken: string; refreshToken: string; user: AuthenticatedUser; previousLogin: PreviousLoginInfo }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password, rememberMe }),
    });
  },
  async me() {
    return request<AuthenticatedUser>('/auth/me');
  },
  async logout() {
    return request<{ loggedOut: boolean }>('/auth/logout', { method: 'POST', body: '{}' });
  },
  async refresh() {
    return request<{ accessToken: string }>('/auth/refresh', { method: 'POST', body: '{}' });
  },
  async changePassword(oldPassword: string, newPassword: string) {
    return request<{ changed: boolean }>('/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({ oldPassword, newPassword }),
    });
  },
  async adminStats() {
    return request<AdminStats>('/admin/stats');
  },
  async gradeApprovalQueue() {
    return request<{ data: GradeQueueItem[]; total: number }>('/admin/grades/pending');
  },
  async securityEvents() {
    return request<SecurityEventsResponse>('/admin/security-events');
  },
  async accessMatrix() {
    return request<{
      roles: any[];
      permissions: any[];
      rolePermissions: any[];
      policyConfig: PolicyConfig;
      emergencyLockoutActive: boolean;
    }>('/admin/access-matrix');
  },
  async auditStats() {
    return request<AuditStatsResponse>('/audit/stats');
  },
  async updateAccessMatrix(policyConfig: PolicyConfig) {
    return request<{ success: boolean; policyConfig: PolicyConfig }>('/admin/access-matrix', {
      method: 'POST',
      body: JSON.stringify({ policyConfig }),
    });
  },
  async toggleEmergencyLockout(active: boolean) {
    return request<{ success: boolean; emergencyLockoutActive: boolean }>('/admin/emergency-lockout', {
      method: 'POST',
      body: JSON.stringify({ active }),
    });
  },
  async auditLogs() {
    return request<{ data: AuditLog[] }>('/audit');
  },
  async auditMy() {
    return request<AuditLog[]>('/audit/my');
  },
  async periods() {
    return request<AcademicPeriod[]>('/periods');
  },
  async activePeriod() {
    return request<AcademicPeriod | null>('/periods/active');
  },
  async courses() {
    return request<{ data: Course[] }>('/courses');
  },
  async course(id: number) {
    return request<{ course: Course; lecturer: AuthenticatedUser | null; students: Array<AuthenticatedUser & { studentId?: string | null; staffId?: string | null }> }>(`/courses/${id}`);
  },
  async myGrades() {
    return request<Grade[]>('/grades/my');
  },
  async myEnrollments() {
    return request<Enrollment[]>('/enrollments/my');
  },
  async users() {
    return request<UsersResponse>('/users');
  },
  async user(id: number) {
    return request(`/users/${id}`);
  },
  async createUser(payload: {
    firstName: string;
    lastName: string;
    email: string;
    password: string;
    roleId: number;
    studentId?: string;
    staffId?: string;
    department?: string;
  }) {
    return request('/users', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  },
  async updateUser(id: number, payload: Record<string, unknown>) {
    return request(`/users/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    });
  },
  async deleteUser(id: number) {
    return request(`/users/${id}`, {
      method: 'DELETE',
    });
  },
  async lockUser(id: number) {
    return request(`/users/${id}/lock`, {
      method: 'POST',
      body: '{}',
    });
  },
  async unlockUser(id: number) {
    return request(`/users/${id}/unlock`, {
      method: 'POST',
      body: '{}',
    });
  },
  async courseStudents(courseId: number) {
    return request<CourseMembersResponse>(`/courses/${courseId}/students`);
  },
  async courseGrades(courseId: number) {
    return request<{ data: Grade[]; total: number; page: number; totalPages: number }>(`/courses/${courseId}/grades`);
  },
  async createGrade(payload: { studentId: number; courseId: number; score: number; remarks?: string }) {
    return request('/grades', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  },
  async transcript() {
    return request<TranscriptResponse>('/grades/transcript');
  },
  async submitGrade(id: number) {
    return request(`/grades/${id}/submit`, { method: 'POST', body: '{}' });
  },
  async approveGrade(id: number) {
    return request(`/grades/${id}/approve`, { method: 'POST', body: '{}' });
  },
  async rejectGrade(id: number) {
    return request(`/grades/${id}/reject`, { method: 'POST', body: '{}' });
  },
  async simulateAccess(
    resource: string,
    action: string,
    context?: {
      resourceId?: string;
      targetStudentId?: number;
      targetCourseId?: number;
      academicPeriodId?: number;
    },
  ) {
    return request<SimulatedAccessDecision>('/access/simulate', {
      method: 'POST',
      body: JSON.stringify({
        resource,
        action,
        resourceId: context?.resourceId,
        context: {
          targetStudentId: context?.targetStudentId,
          targetCourseId: context?.targetCourseId,
          academicPeriodId: context?.academicPeriodId,
        },
      }),
    });
  },
};

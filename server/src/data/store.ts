import bcrypt from 'bcryptjs';
import {
  AcademicPeriod,
  AuditLog,
  AuditOutcome,
  ContextPolicy,
  Course,
  Department,
  Enrollment,
  Grade,
  Permission,
  Role,
  RoleName,
  SeparationOfDutyLog,
  Session,
  User,
  PolicyConfig,
} from '../../../shared/types.js';

export interface AppStore {
  roles: Role[];
  permissions: Permission[];
  rolePermissions: Array<{ roleId: number; permissionId: number }>;
  users: User[];
  sessions: Session[];
  departments: Department[];
  academicPeriods: AcademicPeriod[];
  courses: Course[];
  enrollments: Enrollment[];
  grades: Grade[];
  auditLogs: AuditLog[];
  separationOfDutyLogs: SeparationOfDutyLog[];
  contextPolicies: ContextPolicy[];
  emergencyLockoutActive: boolean;
  policyConfig: PolicyConfig;
  counters: {
    userId: number;
    session: number;
    department: number;
    academicPeriod: number;
    course: number;
    enrollment: number;
    grade: number;
    audit: number;
    sod: number;
    policy: number;
  };
}

const now = () => new Date().toISOString();
const hash = (value: string) => bcrypt.hashSync(value, 12);

export const store: AppStore = {
  roles: [
    { id: 1, name: 'ADMINISTRATOR', description: 'Full system access' },
    { id: 2, name: 'LECTURER', description: 'Manages courses and grades' },
    { id: 3, name: 'STUDENT', description: 'Views own academic data' },
  ],
  permissions: [
    { id: 1, resource: 'users', action: 'read', description: 'Read users' },
    { id: 2, resource: 'users', action: 'write', description: 'Manage users' },
    { id: 3, resource: 'courses', action: 'read', description: 'Read courses' },
    { id: 4, resource: 'courses', action: 'write', description: 'Manage courses' },
    { id: 5, resource: 'enrollments', action: 'read', description: 'Read enrollments' },
    { id: 6, resource: 'enrollments', action: 'write', description: 'Manage enrollments' },
    { id: 7, resource: 'grades', action: 'read', description: 'Read grades' },
    { id: 8, resource: 'grades', action: 'write', description: 'Submit grades' },
    { id: 9, resource: 'grades', action: 'approve', description: 'Approve grades' },
    { id: 10, resource: 'audit', action: 'read', description: 'Read audit logs' },
    { id: 11, resource: 'periods', action: 'write', description: 'Manage periods' },
  ],
  rolePermissions: [
    { roleId: 1, permissionId: 1 },
    { roleId: 1, permissionId: 2 },
    { roleId: 1, permissionId: 3 },
    { roleId: 1, permissionId: 4 },
    { roleId: 1, permissionId: 5 },
    { roleId: 1, permissionId: 6 },
    { roleId: 1, permissionId: 7 },
    { roleId: 1, permissionId: 8 },
    { roleId: 1, permissionId: 9 },
    { roleId: 1, permissionId: 10 },
    { roleId: 1, permissionId: 11 },
    { roleId: 2, permissionId: 3 },
    { roleId: 2, permissionId: 5 },
    { roleId: 2, permissionId: 7 },
    { roleId: 2, permissionId: 8 },
    { roleId: 2, permissionId: 10 },
    { roleId: 3, permissionId: 3 },
    { roleId: 3, permissionId: 5 },
    { roleId: 3, permissionId: 7 },
    { roleId: 3, permissionId: 10 },
  ],
  users: [],
  sessions: [],
  departments: [],
  academicPeriods: [],
  courses: [],
  enrollments: [],
  grades: [],
  auditLogs: [],
  separationOfDutyLogs: [],
  contextPolicies: [],
  emergencyLockoutActive: false,
  policyConfig: {
    matrix: {
      ADMINISTRATOR: { read: true, write: true, delete: true, approve: true },
      LECTURER: { read: true, write: true, delete: false, approve: true },
      STUDENT: { read: true, write: false, delete: false, approve: false },
    },
    associations: {
      enrolledInCourse: { strengthThreshold: 85, timeoutMins: 120, isActive: true },
      assignedLecturer: { verificationDepth: 'Direct Assignment', reauthCycle: '24h', isActive: true },
    },
    environmental: {
      ipRanges: ['10.0.0.0/8', '192.168.1.0/24'],
      timeWindow: { start: '08:00', end: '18:00', blockOutside: true },
      gradingPeriod: { requiredPeriod: 'FINAL_EXAM_PERIOD', daysLeft: 14 },
    },
  },
  counters: {
    userId: 1,
    session: 1,
    department: 1,
    academicPeriod: 1,
    course: 1,
    enrollment: 1,
    grade: 1,
    audit: 1,
    sod: 1,
    policy: 1,
  },
};

function seededUser(input: {
  studentId?: string;
  staffId?: string;
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  roleId: number;
  department?: string;
}): User {
  const timestamp = now();
  return {
    id: store.counters.userId++,
    studentId: input.studentId ?? null,
    staffId: input.staffId ?? null,
    firstName: input.firstName,
    lastName: input.lastName,
    email: input.email,
    passwordHash: hash(input.password),
    roleId: input.roleId,
    department: input.department ?? null,
    isActive: true,
    failedLogins: 0,
    lockedUntil: null,
    lastLogin: null,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

export function resetStore(): void {
  store.users = [];
  store.sessions = [];
  store.departments = [];
  store.academicPeriods = [];
  store.courses = [];
  store.enrollments = [];
  store.grades = [];
  store.auditLogs = [];
  store.separationOfDutyLogs = [];
  store.contextPolicies = [];
  store.emergencyLockoutActive = false;
  store.policyConfig = {
    matrix: {
      ADMINISTRATOR: { read: true, write: true, delete: true, approve: true },
      LECTURER: { read: true, write: true, delete: false, approve: true },
      STUDENT: { read: true, write: false, delete: false, approve: false },
    },
    associations: {
      enrolledInCourse: { strengthThreshold: 85, timeoutMins: 120, isActive: true },
      assignedLecturer: { verificationDepth: 'Direct Assignment', reauthCycle: '24h', isActive: true },
    },
    environmental: {
      ipRanges: ['10.0.0.0/8', '192.168.1.0/24'],
      timeWindow: { start: '08:00', end: '18:00', blockOutside: true },
      gradingPeriod: { requiredPeriod: 'FINAL_EXAM_PERIOD', daysLeft: 14 },
    },
  };
  store.counters = {
    userId: 1,
    session: 1,
    department: 1,
    academicPeriod: 1,
    course: 1,
    enrollment: 1,
    grade: 1,
    audit: 1,
    sod: 1,
    policy: 1,
  };
}

export function seedDemoData(): void {
  resetStore();

  const computerScience = {
    id: store.counters.department++,
    name: 'Computer Science',
    code: 'CS',
    createdAt: now(),
  };
  store.departments.push(computerScience);

  const activePeriod: AcademicPeriod = {
    id: store.counters.academicPeriod++,
    name: 'Semester 2, 2025/2026',
    startDate: '2026-01-05T00:00:00.000Z',
    endDate: '2026-06-30T23:59:59.999Z',
    gradingOpen: '2026-05-01T00:00:00.000Z',
    gradingClose: '2026-06-30T23:59:59.999Z',
    isActive: true,
    createdAt: now(),
  };
  const pastPeriod: AcademicPeriod = {
    id: store.counters.academicPeriod++,
    name: 'Semester 1, 2025/2026',
    startDate: '2025-08-25T00:00:00.000Z',
    endDate: '2025-12-15T23:59:59.999Z',
    gradingOpen: '2025-12-01T00:00:00.000Z',
    gradingClose: '2025-12-10T23:59:59.999Z',
    isActive: false,
    createdAt: now(),
  };
  store.academicPeriods.push(activePeriod, pastPeriod);

  const admin = seededUser({
    staffId: 'ADM-001',
    firstName: 'System',
    lastName: 'Admin',
    email: 'admin@rasac.edu',
    password: 'Admin@123',
    roleId: 1,
  });
  const lecturer1 = seededUser({
    staffId: 'LEC-001',
    firstName: 'Dr. Aris',
    lastName: 'Thorne',
    email: 'dr.thorne@rasac.edu',
    password: 'Lect@123',
    roleId: 2,
    department: 'Computer Science',
  });
  const lecturer2 = seededUser({
    staffId: 'LEC-002',
    firstName: 'Prof.',
    lastName: 'Mensah',
    email: 'prof.mensah@rasac.edu',
    password: 'Lect@123',
    roleId: 2,
    department: 'Computer Science',
  });
  const student1 = seededUser({
    studentId: '11330842',
    firstName: 'Godsway',
    lastName: 'Baniba',
    email: 'godsway.baniba@rasac.edu',
    password: 'Stud@123',
    roleId: 3,
    department: 'Computer Science',
  });
  const student2 = seededUser({
    studentId: '11450289',
    firstName: 'Elena',
    lastName: 'Rodriguez',
    email: 'elena.rodriguez@rasac.edu',
    password: 'Stud@123',
    roleId: 3,
    department: 'Computer Science',
  });
  const student3 = seededUser({
    studentId: '11220911',
    firstName: 'Marcus',
    lastName: 'Thorne',
    email: 'marcus.thorne@rasac.edu',
    password: 'Stud@123',
    roleId: 3,
    department: 'Computer Science',
  });
  const student4 = seededUser({
    studentId: '11330755',
    firstName: 'Liam',
    lastName: "O'Connor",
    email: 'liam.oconnor@rasac.edu',
    password: 'Stud@123',
    roleId: 3,
    department: 'Computer Science',
  });
  const student5 = seededUser({
    studentId: '11440822',
    firstName: 'Sarah',
    lastName: 'Jenkins',
    email: 'sarah.jenkins@rasac.edu',
    password: 'Stud@123',
    roleId: 3,
    department: 'Computer Science',
  });
  store.users.push(admin, lecturer1, lecturer2, student1, student2, student3, student4, student5);

  const cs401: Course = {
    id: store.counters.course++,
    code: 'CS-401',
    title: 'Advanced Cryptography & RASAC',
    credits: 4,
    departmentId: computerScience.id,
    lecturerId: lecturer1.id,
    academicPeriodId: activePeriod.id,
    isActive: true,
    createdAt: now(),
    updatedAt: now(),
  };
  const cs302: Course = {
    id: store.counters.course++,
    code: 'CS302',
    title: 'Database Systems',
    credits: 3,
    departmentId: computerScience.id,
    lecturerId: lecturer1.id,
    academicPeriodId: activePeriod.id,
    isActive: true,
    createdAt: now(),
    updatedAt: now(),
  };
  const cs201: Course = {
    id: store.counters.course++,
    code: 'CS201',
    title: 'Data Structures',
    credits: 3,
    departmentId: computerScience.id,
    lecturerId: lecturer2.id,
    academicPeriodId: activePeriod.id,
    isActive: true,
    createdAt: now(),
    updatedAt: now(),
  };
  store.courses.push(cs401, cs302, cs201);

  const enrollments: Enrollment[] = [
    { id: store.counters.enrollment++, studentId: student1.id, courseId: cs401.id, enrolledAt: '2024-09-12T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student1.id, courseId: cs302.id, enrolledAt: '2024-09-12T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student2.id, courseId: cs401.id, enrolledAt: '2024-09-14T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student2.id, courseId: cs201.id, enrolledAt: '2024-09-14T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student3.id, courseId: cs401.id, enrolledAt: '2024-09-10T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student3.id, courseId: cs302.id, enrolledAt: '2024-09-10T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student4.id, courseId: cs401.id, enrolledAt: '2024-09-12T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student4.id, courseId: cs201.id, enrolledAt: '2024-09-12T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student5.id, courseId: cs401.id, enrolledAt: '2024-09-13T00:00:00.000Z', status: 'ACTIVE' },
    { id: store.counters.enrollment++, studentId: student5.id, courseId: cs302.id, enrolledAt: '2024-09-13T00:00:00.000Z', status: 'ACTIVE' },
  ];
  store.enrollments.push(...enrollments);

  const draftGrade: Grade = {
    id: store.counters.grade++,
    studentId: student1.id,
    courseId: cs401.id,
    submitterId: lecturer1.id,
    approverId: null,
    score: 94,
    grade: 'A',
    remarks: 'Excellent work',
    status: 'DRAFT',
    submittedAt: now(),
    approvedAt: null,
  };
  store.grades.push(draftGrade);

  store.contextPolicies.push({
    id: store.counters.policy++,
    name: 'GradingWindow',
    description: 'Grades may only be submitted while grading is open',
    resource: 'grades',
    action: 'write',
    condition: { requiresActivePeriod: true, allowedHours: [0, 23] },
    isActive: true,
    createdAt: now(),
  });
}

export function roleById(roleId: number): Role {
  const role = store.roles.find((item) => item.id === roleId);
  if (!role) {
    throw new Error(`Unknown role ${roleId}`);
  }
  return role;
}

export function userByEmail(email: string): User | undefined {
  return store.users.find((user) => user.email.toLowerCase() === email.toLowerCase());
}

export function userById(id: number): User | undefined {
  return store.users.find((user) => user.id === id);
}

export function courseById(id: number): Course | undefined {
  return store.courses.find((course) => course.id === id);
}

export function activeAcademicPeriod(): AcademicPeriod | undefined {
  return store.academicPeriods.find((period) => period.isActive);
}

export function enrollmentsForStudent(studentId: number): Enrollment[] {
  return store.enrollments.filter((enrollment) => enrollment.studentId === studentId && enrollment.status === 'ACTIVE');
}

export function enrollmentsForCourse(courseId: number): Enrollment[] {
  return store.enrollments.filter((enrollment) => enrollment.courseId === courseId && enrollment.status === 'ACTIVE');
}

export function gradesForCourse(courseId: number): Grade[] {
  return store.grades.filter((grade) => grade.courseId === courseId);
}

export function gradesForStudent(studentId: number): Grade[] {
  return store.grades.filter((grade) => grade.studentId === studentId);
}

export function auditStats(): Record<string, number> {
  const stats: Record<string, number> = {
    GRANTED: 0,
    DENIED_ROLE: 0,
    DENIED_RELATIONSHIP: 0,
    DENIED_CONTEXT: 0,
    DENIED_SOD: 0,
    ERROR: 0,
  };
  for (const log of store.auditLogs) {
    stats[log.outcome] = (stats[log.outcome] ?? 0) + 1;
  }
  return stats;
}

export function countAuditByOutcome(outcome: AuditOutcome): number {
  return store.auditLogs.filter((entry) => entry.outcome === outcome).length;
}

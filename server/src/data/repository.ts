import bcrypt from 'bcryptjs';
import { pool } from '../db/pool.js';
import type {
  AcademicPeriod,
  AuditLog,
  AuditOutcome,
  ContextPolicy,
  Course,
  Enrollment,
  Grade,
  GradeStatus,
  Permission,
  PolicyConfig,
  Role,
  RoleName,
  SeparationOfDutyLog,
  Session,
  User,
} from '../../../shared/types.js';

type DbUserRow = {
  id: number;
  student_id: string | null;
  staff_id: string | null;
  first_name: string;
  last_name: string;
  email: string;
  password_hash: string;
  role_id: number;
  department: string | null;
  office_location: string | null;
  consultation_hours: string | null;
  is_active: boolean;
  failed_logins: number;
  locked_until: string | null;
  last_login: string | null;
  last_login_ip: string | null;
  created_at: string;
  updated_at: string;
};

type DbCourseRow = {
  id: number;
  code: string;
  title: string;
  credits: number;
  department_id: number;
  lecturer_id: number;
  academic_period_id: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
};

type DbGradeRow = {
  id: number;
  student_id: number;
  course_id: number;
  submitter_id: number;
  approver_id: number | null;
  score: number;
  grade: string;
  remarks: string | null;
  status: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED';
  submitted_at: string;
  approved_at: string | null;
};

type DbAuditRow = {
  id: number;
  user_id: number | null;
  action: string;
  resource: string;
  resource_id: string | null;
  outcome: AuditOutcome;
  deny_reason: string | null;
  ip_address: string | null;
  user_agent: string | null;
  request_path: string | null;
  metadata: Record<string, unknown> | null;
  timestamp: string;
};

type DbEnrollmentRow = {
  id: number;
  student_id: number;
  course_id: number;
  enrolled_at: string;
};

type DbRolePermissionRow = {
  role_id: number;
  permission_id: number;
};

type DbSystemStateRow = {
  emergency_lockout_active: boolean;
  policy_config: PolicyConfig;
};

type DbSessionRow = {
  id: string;
  user_id: number;
  refresh_token: string;
  ip_address: string | null;
  user_agent: string | null;
  is_revoked: boolean;
  expires_at: string;
  created_at: string;
};

type PendingGradeRow = {
  id: number;
  student_id: number;
  student_name: string;
  course_id: number;
  course_code: string;
  course_title: string;
  score: number;
  grade: string;
  submitter_id: number;
  submitter_name: string;
  status: string;
  sod_risk: boolean;
  submitted_at: string;
};

const basePolicyConfig: PolicyConfig = {
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
    timeWindow: { start: '00:00', end: '23:59', blockOutside: false },
    gradingPeriod: { requiredPeriod: 'FINAL_EXAM_PERIOD', daysLeft: 14 },
  },
};

const toIso = (value: unknown): string | null => {
  if (value == null) return null;
  return new Date(value as string).toISOString();
};

const mapUser = (row: DbUserRow, roleName: RoleName): User => ({
  id: row.id,
  studentId: row.student_id,
  staffId: row.staff_id,
  firstName: row.first_name,
  lastName: row.last_name,
  email: row.email,
  passwordHash: row.password_hash,
  roleId: row.role_id,
  department: row.department,
  officeLocation: row.office_location,
  consultationHours: row.consultation_hours,
  isActive: row.is_active,
  failedLogins: row.failed_logins,
  lockedUntil: toIso(row.locked_until),
  lastLogin: toIso(row.last_login),
  lastLoginIp: row.last_login_ip,
  createdAt: toIso(row.created_at) ?? new Date().toISOString(),
  updatedAt: toIso(row.updated_at) ?? new Date().toISOString(),
});

const mapRole = (row: { id: number; name: RoleName; description: string | null }): Role => ({
  id: row.id,
  name: row.name,
  description: row.description,
});

const mapPermission = (row: { id: number; resource: string; action: string; description: string | null }): Permission => ({
  id: row.id,
  resource: row.resource,
  action: row.action,
  description: row.description,
});

const mapDepartment = (row: { id: number; name: string; code: string; created_at: string }) => ({
  id: row.id,
  name: row.name,
  code: row.code,
  createdAt: new Date(row.created_at).toISOString(),
});

const mapPeriod = (row: {
  id: number;
  name: string;
  start_date: string;
  end_date: string;
  grading_open: string;
  grading_close: string;
  is_active: boolean;
  created_at: string;
}): AcademicPeriod => ({
  id: row.id,
  name: row.name,
  startDate: new Date(row.start_date).toISOString(),
  endDate: new Date(row.end_date).toISOString(),
  gradingOpen: new Date(row.grading_open).toISOString(),
  gradingClose: new Date(row.grading_close).toISOString(),
  isActive: row.is_active,
  createdAt: new Date(row.created_at).toISOString(),
});

const mapCourse = (row: DbCourseRow): Course => ({
  id: row.id,
  code: row.code,
  title: row.title,
  credits: row.credits,
  departmentId: row.department_id,
  lecturerId: row.lecturer_id,
  academicPeriodId: row.academic_period_id,
  isActive: row.is_active,
  createdAt: new Date(row.created_at).toISOString(),
  updatedAt: new Date(row.updated_at).toISOString(),
});

const mapEnrollment = (row: DbEnrollmentRow): Enrollment => ({
  id: row.id,
  studentId: row.student_id,
  courseId: row.course_id,
  enrolledAt: new Date(row.enrolled_at).toISOString(),
});

const mapGrade = (row: DbGradeRow): Grade => ({
  id: row.id,
  studentId: row.student_id,
  courseId: row.course_id,
  submitterId: row.submitter_id,
  approverId: row.approver_id,
  score: Number(row.score),
  grade: row.grade,
  remarks: row.remarks,
  status: row.status,
  submittedAt: new Date(row.submitted_at).toISOString(),
  approvedAt: row.approved_at ? new Date(row.approved_at).toISOString() : null,
});

const mapAudit = (row: DbAuditRow): AuditLog => ({
  id: row.id,
  userId: row.user_id,
  action: row.action,
  resource: row.resource,
  resourceId: row.resource_id,
  outcome: row.outcome,
  denyReason: (row.deny_reason as any) ?? null,
  ipAddress: row.ip_address,
  userAgent: row.user_agent,
  requestPath: row.request_path,
  metadata: row.metadata,
  timestamp: new Date(row.timestamp).toISOString(),
});

const mapSession = (row: DbSessionRow): Session => ({
  id: row.id,
  userId: row.user_id,
  refreshToken: row.refresh_token,
  ipAddress: row.ip_address,
  userAgent: row.user_agent,
  isRevoked: row.is_revoked,
  expiresAt: new Date(row.expires_at).toISOString(),
  createdAt: new Date(row.created_at).toISOString(),
});

const mapRolePermission = (row: DbRolePermissionRow) => row;

async function query<T>(text: string, values: unknown[] = []): Promise<T[]> {
  const result = await pool.query(text, values);
  return result.rows as T[];
}

async function queryOne<T>(text: string, values: unknown[] = []): Promise<T | null> {
  const rows = await query<T>(text, values);
  return rows[0] ?? null;
}

export async function initializeDatabase(): Promise<void> {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS roles (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      description TEXT
    );

    CREATE TABLE IF NOT EXISTS permissions (
      id BIGSERIAL PRIMARY KEY,
      resource TEXT NOT NULL,
      action TEXT NOT NULL,
      description TEXT,
      UNIQUE (resource, action)
    );

    CREATE TABLE IF NOT EXISTS role_permissions (
      role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
      permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
      PRIMARY KEY (role_id, permission_id)
    );

    CREATE TABLE IF NOT EXISTS departments (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      code TEXT NOT NULL UNIQUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS academic_periods (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      start_date TIMESTAMPTZ NOT NULL,
      end_date TIMESTAMPTZ NOT NULL,
      grading_open TIMESTAMPTZ NOT NULL,
      grading_close TIMESTAMPTZ NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS users (
      id BIGSERIAL PRIMARY KEY,
      student_id TEXT UNIQUE,
      staff_id TEXT UNIQUE,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      role_id BIGINT NOT NULL REFERENCES roles(id),
      department TEXT,
      office_location TEXT,
      consultation_hours TEXT,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      failed_logins INTEGER NOT NULL DEFAULT 0,
      locked_until TIMESTAMPTZ,
      last_login TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS sessions (
      id UUID PRIMARY KEY,
      user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      refresh_token TEXT NOT NULL UNIQUE,
      ip_address TEXT,
      user_agent TEXT,
      is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
      expires_at TIMESTAMPTZ NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS courses (
      id BIGSERIAL PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      title TEXT NOT NULL,
      credits INTEGER NOT NULL DEFAULT 3,
      department_id BIGINT NOT NULL REFERENCES departments(id),
      lecturer_id BIGINT NOT NULL REFERENCES users(id),
      academic_period_id BIGINT NOT NULL REFERENCES academic_periods(id),
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS enrollments (
      id BIGSERIAL PRIMARY KEY,
      student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
      enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      status TEXT NOT NULL DEFAULT 'ACTIVE',
      UNIQUE (student_id, course_id)
    );

    CREATE TABLE IF NOT EXISTS grades (
      id BIGSERIAL PRIMARY KEY,
      student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
      submitter_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      approver_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
      score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
      grade TEXT NOT NULL,
      remarks TEXT,
      status TEXT NOT NULL DEFAULT 'DRAFT',
      submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      approved_at TIMESTAMPTZ,
      UNIQUE (student_id, course_id)
    );

    CREATE TABLE IF NOT EXISTS audit_logs (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
      action TEXT NOT NULL,
      resource TEXT NOT NULL,
      resource_id TEXT,
      outcome TEXT NOT NULL,
      deny_reason TEXT,
      ip_address TEXT,
      user_agent TEXT,
      request_path TEXT,
      metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
      timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS separation_of_duty_logs (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      violation TEXT NOT NULL,
      attempted TEXT NOT NULL,
      blocked BOOLEAN NOT NULL DEFAULT TRUE,
      timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS context_policies (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      description TEXT NOT NULL,
      resource TEXT NOT NULL,
      action TEXT NOT NULL,
      condition JSONB NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS system_state (
      id SMALLINT PRIMARY KEY DEFAULT 1,
      emergency_lockout_active BOOLEAN NOT NULL DEFAULT FALSE,
      policy_config JSONB NOT NULL
    );
  `);

  await pool.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_ip TEXT;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS office_location TEXT;
    ALTER TABLE users ADD COLUMN IF NOT EXISTS consultation_hours TEXT;
  `);

  await pool.query(
    `INSERT INTO system_state (id, emergency_lockout_active, policy_config)
     VALUES (1, FALSE, $1::jsonb)
     ON CONFLICT (id) DO NOTHING`,
    [JSON.stringify(basePolicyConfig)]
  );

  const roleCount = await queryOne<{ count: string }>('SELECT COUNT(*)::text AS count FROM roles');
  if (Number(roleCount?.count ?? '0') > 0) {
    return;
  }

  const password = (value: string) => bcrypt.hashSync(value, 12);
  await pool.query('BEGIN');
  try {
      const roles = await query<{ id: number; name: RoleName }>(
        `INSERT INTO roles (code, name, description) VALUES
          ('ADMINISTRATOR', 'Administrator', 'Full system access'),
          ('LECTURER', 'Lecturer', 'Manages courses and grades'),
          ('STUDENT', 'Student', 'Views own academic data')
        RETURNING id, code AS name`
      );
    

    
        const permissions = await query<{ id: number; resource: string; action: string }>(
          `INSERT INTO permissions (code, name, resource, action, description) VALUES
            ('users:read',        'Read Users',         'users',       'read',    'Read users'),
            ('users:write',       'Manage Users',        'users',       'write',   'Manage users'),
            ('courses:read',      'Read Courses',        'courses',     'read',    'Read courses'),
            ('courses:write',     'Manage Courses',      'courses',     'write',   'Manage courses'),
            ('enrollments:read',  'Read Enrollments',    'enrollments', 'read',    'Read enrollments'),
            ('enrollments:write', 'Manage Enrollments',  'enrollments', 'write',   'Manage enrollments'),
            ('grades:read',       'Read Grades',         'grades',      'read',    'Read grades'),
            ('grades:write',      'Submit Grades',       'grades',      'write',   'Submit grades'),
            ('grades:approve',    'Approve Grades',      'grades',      'approve', 'Approve grades'),
            ('audit:read',        'Read Audit Logs',     'audit',       'read',    'Read audit logs'),
            ('periods:write',     'Manage Periods',      'periods',     'write',   'Manage periods'),
            ('my-profile:write'), 'Edit Own Profile',    'my-profile',  'write',   'Edit own contact info')
          RETURNING id, resource, action`
        );

    const byRole = new Map(roles.map((row) => [row.name, row.id] as const));
    const byPerm = new Map(permissions.map((row) => [`${row.resource}:${row.action}`, row.id] as const));
    const rolePerms: Array<[RoleName, string, string]> = [
      ['ADMINISTRATOR', 'users', 'read'],
      ['ADMINISTRATOR', 'users', 'write'],
      ['ADMINISTRATOR', 'courses', 'read'],
      ['ADMINISTRATOR', 'courses', 'write'],
      ['ADMINISTRATOR', 'enrollments', 'read'],
      ['ADMINISTRATOR', 'enrollments', 'write'],
      ['ADMINISTRATOR', 'grades', 'read'],
      ['ADMINISTRATOR', 'grades', 'write'],
      ['ADMINISTRATOR', 'grades', 'approve'],
      ['ADMINISTRATOR', 'audit', 'read'],
      ['ADMINISTRATOR', 'periods', 'write'],
      ['LECTURER', 'courses', 'read'],
      ['LECTURER', 'enrollments', 'read'],
      ['LECTURER', 'grades', 'read'],
      ['LECTURER', 'grades', 'write'],
      ['LECTURER', 'audit', 'read'],
      ['STUDENT', 'courses', 'read'],
      ['STUDENT', 'enrollments', 'read'],
      ['STUDENT', 'grades', 'read'],
      ['STUDENT', 'audit', 'read'],
      ['ADMINISTRATOR', 'my-profile', 'write'],
      ['LECTURER', 'my-profile', 'write'],
      ['STUDENT', 'my-profile', 'write'],
    ];

    for (const [roleName, resource, action] of rolePerms) {
      await pool.query(
        'INSERT INTO role_permissions (role_id, permission_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [byRole.get(roleName), byPerm.get(`${resource}:${action}`)]
      );
    }

    const department = await queryOne<{ id: number }>(
      `INSERT INTO departments (name, code) VALUES ('Computer Science', 'CS') RETURNING id`
    );
    const activePeriod = await queryOne<{ id: number }>(
      `INSERT INTO academic_periods (name, start_date, end_date, grading_open, grading_close, is_active)
       VALUES ('Semester 2, 2025/2026', '2026-01-05T00:00:00.000Z', '2026-06-30T23:59:59.999Z', '2026-05-01T00:00:00.000Z', '2026-06-30T23:59:59.999Z', TRUE)
       RETURNING id`
    );
    await pool.query(
      `INSERT INTO academic_periods (name, start_date, end_date, grading_open, grading_close, is_active)
       VALUES ('Semester 1, 2025/2026', '2025-08-25T00:00:00.000Z', '2025-12-15T23:59:59.999Z', '2025-12-01T00:00:00.000Z', '2025-12-10T23:59:59.999Z', FALSE)`
    );

    
    const users = await query<DbUserRow>(
      `INSERT INTO users (
        student_id, staff_id, first_name, last_name, full_name, email, password_hash, role_id, department, is_active, failed_logins, locked_until, last_login
      ) VALUES
        (NULL, 'ADM-001', 'System', 'Admin', 'System Admin', 'admin@rasac.edu', $1, $2, NULL, TRUE, 0, NULL, NULL),
        (NULL, 'LEC-001', 'Dr. Aris', 'Thorne', 'Dr. Aris Thorne', 'dr.thorne@rasac.edu', $3, $4, 'Computer Science', TRUE, 0, NULL, NULL),
        (NULL, 'LEC-002', 'Prof.', 'Mensah', 'Prof. Mensah', 'prof.mensah@rasac.edu', $5, $4, 'Computer Science', TRUE, 0, NULL, NULL),
        ('11330842', NULL, 'Godsway', 'Baniba', 'Godsway Baniba', 'godsway.baniba@rasac.edu', $6, $7, 'Computer Science', TRUE, 0, NULL, NULL),
        ('11450289', NULL, 'Elena', 'Rodriguez', 'Elena Rodriguez', 'elena.rodriguez@rasac.edu', $6, $7, 'Computer Science', TRUE, 0, NULL, NULL),
        ('11220911', NULL, 'Marcus', 'Thorne', 'Marcus Thorne', 'marcus.thorne@rasac.edu', $6, $7, 'Computer Science', TRUE, 0, NULL, NULL),
        ('11330755', NULL, 'Liam', 'O''Connor', 'Liam O''Connor', 'liam.oconnor@rasac.edu', $6, $7, 'Computer Science', TRUE, 0, NULL, NULL),
        ('11440822', NULL, 'Sarah', 'Jenkins', 'Sarah Jenkins', 'sarah.jenkins@rasac.edu', $6, $7, 'Computer Science', TRUE, 0, NULL, NULL)
      RETURNING *`,
      [
        password('Admin@123'),
        byRole.get('ADMINISTRATOR'),
        password('Lect@123'),
        byRole.get('LECTURER'),
        password('Lect@123'),
        password('Stud@123'),
        byRole.get('STUDENT'),
      ]
    );

    const lecturer1 = users.find((user) => user.email === 'dr.thorne@rasac.edu');
    const lecturer2 = users.find((user) => user.email === 'prof.mensah@rasac.edu');
    const student1 = users.find((user) => user.email === 'godsway.baniba@rasac.edu');
    const student2 = users.find((user) => user.email === 'elena.rodriguez@rasac.edu');
    const student3 = users.find((user) => user.email === 'marcus.thorne@rasac.edu');
    const student4 = users.find((user) => user.email === 'liam.oconnor@rasac.edu');
    const student5 = users.find((user) => user.email === 'sarah.jenkins@rasac.edu');

    const courses = await query<{ id: number }>(
      `INSERT INTO courses (code, title, credits, department_id, lecturer_id, academic_period_id, is_active)
       VALUES
        ('CS-401', 'Advanced Cryptography & RASAC', 4, $1, $2, $3, TRUE),
        ('CS302', 'Database Systems', 3, $1, $2, $3, TRUE),
        ('CS201', 'Data Structures', 3, $1, $4, $3, TRUE)
       RETURNING id`,
      [department?.id, lecturer1?.id, activePeriod?.id, lecturer2?.id]
    );
    const [cs401, cs302, cs201] = courses;

    const enrollments = [
      [student1?.id, cs401.id],
      [student1?.id, cs302.id],
      [student2?.id, cs401.id],
      [student2?.id, cs201.id],
      [student3?.id, cs401.id],
      [student3?.id, cs302.id],
      [student4?.id, cs401.id],
      [student4?.id, cs201.id],
      [student5?.id, cs401.id],
      [student5?.id, cs302.id],
    ] as Array<[number | undefined, number]>;
    for (const [studentId, courseId] of enrollments) {
      if (!studentId) continue;
      await pool.query(
        `INSERT INTO enrollments (student_id, course_id, enrolled_at)
         VALUES ($1, $2, NOW())
         ON CONFLICT DO NOTHING`,
        [studentId, courseId]
      );
    }

    if (lecturer1 && student1) {
      await pool.query(
        `INSERT INTO grades (student_id, course_id, submitter_id, approver_id, score, grade, remarks, status, submitted_at, approved_at)
         VALUES ($1, $2, $3, NULL, 94, 'A', 'Excellent work', 'DRAFT', NOW(), NULL)
         ON CONFLICT DO NOTHING`,
        [student1.id, cs401.id, lecturer1.id]
      );
    }

    await pool.query(
      `INSERT INTO context_policies (name, description, resource, action, condition, is_active)
       VALUES ('GradingWindow', 'Grades may only be submitted while grading is open', 'grades', 'write', '{"requiresActivePeriod": true, "allowedHours": [0, 23]}'::jsonb, TRUE)
       ON CONFLICT DO NOTHING`
    );

    await pool.query('COMMIT');
  } catch (error) {
    await pool.query('ROLLBACK');
    throw error;
  }
}

export async function listRoles(): Promise<Role[]> {
  const rows = await query<{ id: number; name: RoleName; description: string | null }>('SELECT id, code AS name, description FROM roles ORDER BY id');
  return rows.map(mapRole);
}

export async function listPermissions(): Promise<Permission[]> {
  const rows = await query<{ id: number; resource: string; action: string; description: string | null }>(
    'SELECT id, resource, action, description FROM permissions ORDER BY id'
  );
  return rows.map(mapPermission);
}

export async function countActiveSessions(): Promise<number> {
  const row = await queryOne<{ count: string }>(
    `SELECT COUNT(*)::text AS count FROM sessions WHERE is_revoked = FALSE AND expires_at > NOW()`
  );
  return Number(row?.count ?? '0');
}

export async function countActiveCourses(): Promise<number> {
  const row = await queryOne<{ count: string }>('SELECT COUNT(*)::text AS count FROM courses WHERE is_active = TRUE');
  return Number(row?.count ?? '0');
}

export async function countGradeSubmissions(): Promise<number> {
  const row = await queryOne<{ count: string }>('SELECT COUNT(*)::text AS count FROM grades');
  return Number(row?.count ?? '0');
}

export async function listRolePermissions(): Promise<DbRolePermissionRow[]> {
  return query<DbRolePermissionRow>('SELECT role_id, permission_id FROM role_permissions ORDER BY role_id, permission_id');
}

export async function permissionsForRole(roleId: number): Promise<Array<{ resource: string; action: string }>> {
  const rows = await query<{ resource: string; action: string }>(
    `SELECT p.resource, p.action
     FROM role_permissions rp
     JOIN permissions p ON p.id = rp.permission_id
     WHERE rp.role_id = $1
     ORDER BY p.resource, p.action`,
    [roleId]
  );
  return rows;
}

export async function roleById(roleId: number): Promise<Role | null> {
  const row = await queryOne<{ id: number; name: RoleName; description: string | null }>('SELECT id, code AS name, description FROM roles WHERE id = $1', [roleId]);
  return row ? mapRole(row) : null;
}

// repository.ts

export async function userByEmail(email: string): Promise<(User & { roleName: RoleName }) | null> {
  const row = await queryOne<DbUserRow & { role_name: RoleName }>(
    `SELECT u.*, r.code AS role_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     WHERE lower(u.email) = lower($1)`,
    [email]
  );
  return row ? { ...mapUser(row, row.role_name), roleName: row.role_name } : null;
}

export async function userById(id: number): Promise<(User & { roleName: RoleName }) | null> {
  const row = await queryOne<DbUserRow & { role_name: RoleName }>(
    `SELECT u.*, r.code AS role_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     WHERE u.id = $1`,
    [id]
  );
  return row ? { ...mapUser(row, row.role_name), roleName: row.role_name } : null;
}

export async function listUsers(): Promise<Array<{
  id: number;
  fullName: string;
  email: string;
  role: RoleName;
  department: string | null;
  officeLocation: string | null;
  consultationHours: string | null;
  isActive: boolean;
  studentId: string | null;
  staffId: string | null;
  lastLogin: string | null;
}>> {
  const rows = await query<DbUserRow & { role_name: RoleName }>(
    `SELECT u.*, r.code AS role_name
     FROM users u
     JOIN roles r ON r.id = u.role_id
     ORDER BY u.id`
  );
  return rows.map((row) => ({
    id: row.id,
    fullName: `${row.first_name} ${row.last_name}`,
    email: row.email,
    role: row.role_name,
    department: row.department,
    officeLocation: row.office_location,
    consultationHours: row.consultation_hours,
    isActive: row.is_active,
    studentId: row.student_id,
    staffId: row.staff_id,
    lastLogin: toIso(row.last_login),
  }));
}

export async function listPendingGradesForAdmin(): Promise<Array<{
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
  status: GradeStatus;
  sodRisk: boolean;
  submittedAt: string;
}>> {
  const rows = await query<PendingGradeRow>(
    `SELECT
       g.id,
       g.student_id,
       concat(s.first_name, ' ', s.last_name) AS student_name,
       g.course_id,
       c.code AS course_code,
       c.title AS course_title,
       g.score,
       g.grade,
       g.submitter_id,
       concat(sub.first_name, ' ', sub.last_name) AS submitter_name,
       g.status,
       EXISTS (
         SELECT 1 FROM separation_of_duty_logs sdl
         WHERE sdl.user_id = g.submitter_id AND sdl.blocked = TRUE
       ) AS sod_risk,
       g.submitted_at
     FROM grades g
     JOIN users s   ON s.id   = g.student_id
     JOIN courses c ON c.id   = g.course_id
     JOIN users sub ON sub.id = g.submitter_id
     WHERE g.status IN ('SUBMITTED', 'REJECTED')
     ORDER BY g.submitted_at DESC`
  );
  return rows.map((row) => ({
    id: row.id,
    studentId: row.student_id,
    studentName: row.student_name,
    courseId: row.course_id,
    courseCode: row.course_code,
    courseTitle: row.course_title,
    score: Number(row.score),
    grade: row.grade,
    submitterId: row.submitter_id,
    submitterName: row.submitter_name,
    status: row.status as GradeStatus,
    sodRisk: Boolean(row.sod_risk),
    submittedAt: new Date(row.submitted_at).toISOString(),
  }));
}

// Replace the entire createUser function with this:
export async function createUser(input: {
  firstName: string;
  lastName: string;
  email: string;
  passwordHash: string;
  roleId: number;
  studentId?: string | null;
  staffId?: string | null;
  department?: string | null;
}): Promise<User> {
  await pool.query('BEGIN');
  try {
    const row = await queryOne<DbUserRow>(
      `INSERT INTO users (
    first_name, last_name, full_name, email, password_hash, role_id, student_id, staff_id, department, is_active, failed_logins
  ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, TRUE, 0)
  RETURNING *`,
      [input.firstName, input.lastName, `${input.firstName} ${input.lastName}`,
      input.email, input.passwordHash, input.roleId,
      input.studentId ?? null, input.staffId ?? null, input.department ?? null]
    );
    if (!row) throw new Error('Failed to create user');



    await pool.query('COMMIT');
    return mapUser(row, 'STUDENT');
  } catch (error) {
    await pool.query('ROLLBACK');
    throw error;
  }
}

export async function getUserDetail(id: number) {
  const user = await userById(id);
  if (!user) return null;
  return {
    ...(await buildAuthUser(user.id)),
    isActive: user.isActive,
    academicAssociations: {
      lecturedCourses: (await listCourses()).filter((course) => course.lecturerId === user.id),
      enrollments: await enrollmentsForStudent(user.id),
      gradesSubmitted: (await listGradesByStudent(user.id)).filter((grade) => grade.submitterId === user.id),
    },
  };
}

export async function updateUserById(id: number, patch: Partial<{
  firstName: string;
  lastName: string;
  department: string | null;
  officeLocation: string | null;
  consultationHours: string | null;
  roleId: number;
  isActive: boolean;
  lockedUntil: string | null;
  failedLogins: number;
  lastLogin: string | null;
  lastLoginIp: string | null;
  passwordHash: string;
}>): Promise<User | null> {
  const current = await queryOne<DbUserRow>('SELECT * FROM users WHERE id = $1', [id]);
  if (!current) return null;
  const next = {
    first_name: patch.firstName ?? current.first_name,
    last_name: patch.lastName ?? current.last_name,
    department: patch.department ?? current.department,
    office_location: patch.officeLocation === undefined ? current.office_location : patch.officeLocation,
    consultation_hours: patch.consultationHours === undefined ? current.consultation_hours : patch.consultationHours,
    role_id: patch.roleId ?? current.role_id,
    is_active: typeof patch.isActive === 'boolean' ? patch.isActive : current.is_active,
    locked_until: patch.lockedUntil ?? current.locked_until,
    failed_logins: patch.failedLogins ?? current.failed_logins,
    last_login: patch.lastLogin ?? current.last_login,
    last_login_ip: patch.lastLoginIp ?? current.last_login_ip,
    password_hash: patch.passwordHash ?? current.password_hash,
  };
  const row = await queryOne<DbUserRow>(
    `UPDATE users
     SET first_name = $2,
         last_name = $3,
         department = $4,
         role_id = $5,
         is_active = $6,
         locked_until = $7,
         failed_logins = $8,
         last_login = $9,
         last_login_ip = $10,
         password_hash = $11,
         office_location = $12,
         consultation_hours = $13,
         updated_at = NOW()
     WHERE id = $1
     RETURNING *`,
    [id, next.first_name, next.last_name, next.department, next.role_id, next.is_active, next.locked_until, next.failed_logins, next.last_login, next.last_login_ip, next.password_hash, next.office_location, next.consultation_hours]
  );
  if (patch.roleId !== undefined) {
    await pool.query(
      `UPDATE users SET role_id = $2 WHERE id = $1`,
      [id, patch.roleId]
    );
  }
  return row ? mapUser(row, 'STUDENT') : null;
}

export async function revokeUserSessions(userId: number): Promise<void> {
  await pool.query('UPDATE sessions SET is_revoked = TRUE WHERE user_id = $1', [userId]);
}

export async function getSessionByRefreshToken(refreshToken: string): Promise<Session | null> {
  const row = await queryOne<DbSessionRow>('SELECT * FROM sessions WHERE refresh_token = $1', [refreshToken]);
  return row ? mapSession(row) : null;
}

export async function getSessionById(id: string): Promise<Session | null> {
  const row = await queryOne<DbSessionRow>('SELECT * FROM sessions WHERE id = $1', [id]);
  return row ? mapSession(row) : null;
}

export async function createSession(input: {
  userId: number;
  sessionId: string;
  refreshToken: string;
  ipAddress?: string | null;
  userAgent?: string | null;
}): Promise<{ sessionId: string; refreshToken: string }> {
  await pool.query(
    `INSERT INTO sessions (id, user_id, refresh_token, ip_address, user_agent, is_revoked, expires_at)
     VALUES ($1, $2, $3, $4, $5, FALSE, NOW() + INTERVAL '7 days')`,
    [input.sessionId, input.userId, input.refreshToken, input.ipAddress ?? null, input.userAgent ?? null]
  );
  return { sessionId: input.sessionId, refreshToken: input.refreshToken };
}

export async function revokeSession(refreshToken: string): Promise<void> {
  await pool.query('UPDATE sessions SET is_revoked = TRUE WHERE refresh_token = $1', [refreshToken]);
}

export async function listCourses(viewer?: { id: number; role: RoleName }): Promise<Course[]> {
  let sql = 'SELECT c.* FROM courses c';
  const values: unknown[] = [];

  if (viewer?.role === 'LECTURER') {
    sql += ' WHERE c.lecturer_id = $1';
    values.push(viewer.id);
  } else if (viewer?.role === 'STUDENT') {
    sql += ` JOIN enrollments e ON e.course_id = c.id AND e.student_id = $1`;
    values.push(viewer.id);
  }
  

  sql += ' ORDER BY c.id';
  const rows = await query<DbCourseRow>(sql, values);
  return rows.map(mapCourse);
}

export async function courseById(id: number): Promise<Course | null> {
  const row = await queryOne<DbCourseRow>('SELECT * FROM courses WHERE id = $1', [id]);
  return row ? mapCourse(row) : null;
}

export async function createCourse(input: {
  code: string;
  title: string;
  credits: number;
  departmentId: number;
  lecturerId: number;
  academicPeriodId: number;
}): Promise<Course> {
  const row = await queryOne<DbCourseRow>(
    `INSERT INTO courses (code, title, credits, department_id, lecturer_id, academic_period_id, is_active)
     VALUES ($1, $2, $3, $4, $5, $6, TRUE)
     RETURNING *`,
    [input.code, input.title, input.credits, input.departmentId, input.lecturerId, input.academicPeriodId]
  );
  if (!row) throw new Error('Failed to create course');
  return mapCourse(row);
}

export async function courseStudents(courseId: number): Promise<Array<{ id: number; fullName: string; email: string; role: RoleName; studentId: string | null; staffId: string | null; department: string | null; officeLocation: string | null; consultationHours: string | null; isActive: boolean }>> {
  const rows = await query<DbUserRow & { role_name: RoleName }>(
    `SELECT u.*, r.code AS role_name
     FROM enrollments e
     JOIN users u ON u.id = e.student_id
     JOIN roles r ON r.id = u.role_id
     WHERE e.course_id = $1
     ORDER BY u.last_name, u.first_name`,
    [courseId]
  );
  return rows.map((row) => ({
    id: row.id,
    fullName: `${row.first_name} ${row.last_name}`,
    email: row.email,
    role: row.role_name,
    studentId: row.student_id,
    staffId: row.staff_id,
    department: row.department,
    officeLocation: row.office_location,
    consultationHours: row.consultation_hours,
    isActive: row.is_active,
  }));
}

export async function courseEnrollments(courseId: number): Promise<Enrollment[]> {
  const rows = await query<DbEnrollmentRow>('SELECT * FROM enrollments WHERE course_id = $1 ORDER BY id', [courseId]);
  return rows.map(mapEnrollment);
}

export async function enrollmentsForStudent(studentId: number): Promise<Enrollment[]> {
  const rows = await query<DbEnrollmentRow>('SELECT * FROM enrollments WHERE student_id = $1 ORDER BY id', [studentId]);
  return rows.map(mapEnrollment);
}

export async function enrollmentsForCourse(courseId: number): Promise<Enrollment[]> {
  return courseEnrollments(courseId);
}

export async function createEnrollment(input: { studentId: number; courseId: number }): Promise<Enrollment> {
  const row = await queryOne<DbEnrollmentRow>(
    `INSERT INTO enrollments (student_id, course_id, enrolled_at)
     VALUES ($1, $2, NOW())
     ON CONFLICT (student_id, course_id) DO UPDATE SET enrolled_at = NOW()
     RETURNING *`,
    [input.studentId, input.courseId]
  );
  if (!row) throw new Error('Failed to create enrollment');
  return mapEnrollment(row);
}

export async function dropEnrollmentById(id: number): Promise<void> {
 await pool.query(`DELETE FROM enrollments WHERE id = $1`, [id]);
}

export async function listGradesByStudent(studentId: number): Promise<Grade[]> {
  const rows = await query<DbGradeRow>('SELECT * FROM grades WHERE student_id = $1 ORDER BY submitted_at DESC', [studentId]);
  return rows.map(mapGrade);
}

export async function listGradesByCourse(courseId: number): Promise<Grade[]> {
  const rows = await query<DbGradeRow>('SELECT * FROM grades WHERE course_id = $1 ORDER BY submitted_at DESC', [courseId]);
  return rows.map(mapGrade);
}

export async function getGradeById(id: number): Promise<Grade | null> {
  const row = await queryOne<DbGradeRow>('SELECT * FROM grades WHERE id = $1', [id]);
  return row ? mapGrade(row) : null;
}

export async function createGrade(input: {
  studentId: number;
  courseId: number;
  submitterId: number;
  score: number;
  grade: string;
  remarks?: string | null;
}): Promise<Grade> {
  const row = await queryOne<DbGradeRow>(
    `INSERT INTO grades (student_id, course_id, submitter_id, approver_id, score, grade, remarks, status, submitted_at, approved_at)
     VALUES ($1, $2, $3, NULL, $4, $5, $6, 'DRAFT', NOW(), NULL)
     ON CONFLICT (student_id, course_id)
     DO UPDATE SET submitter_id = EXCLUDED.submitter_id, score = EXCLUDED.score, grade = EXCLUDED.grade, remarks = EXCLUDED.remarks, status = 'DRAFT', submitted_at = NOW(), approved_at = NULL
     RETURNING *`,
    [input.studentId, input.courseId, input.submitterId, input.score, input.grade, input.remarks ?? null]
  );
  if (!row) throw new Error('Failed to create grade');
  return mapGrade(row);
}

export async function updateGradeById(id: number, patch: { score?: number; grade?: string; remarks?: string | null }): Promise<Grade | null> {
  const row = await queryOne<DbGradeRow>(
    `UPDATE grades
     SET score = COALESCE($2, score),
         grade = COALESCE($3, grade),
         remarks = COALESCE($4, remarks)
     WHERE id = $1
     RETURNING *`,
    [id, patch.score ?? null, patch.grade ?? null, patch.remarks ?? null]
  );
  return row ? mapGrade(row) : null;
}

export async function setGradeStatus(id: number, status: DbGradeRow['status'], approverId?: number | null): Promise<Grade | null> {
  const row = await queryOne<DbGradeRow>(
    `UPDATE grades
     SET status = $2,
         approver_id = COALESCE($3, approver_id),
         approved_at = CASE WHEN $2 = 'APPROVED' THEN NOW() ELSE approved_at END
     WHERE id = $1
     RETURNING *`,
    [id, status, approverId ?? null]
  );
  return row ? mapGrade(row) : null;
}

export async function listAuditLogs(): Promise<AuditLog[]> {
  const rows = await query<DbAuditRow>('SELECT * FROM audit_logs ORDER BY timestamp DESC, id DESC');
  return rows.map(mapAudit);
}

export async function listMyAuditLogs(userId: number): Promise<AuditLog[]> {
  const rows = await query<DbAuditRow>('SELECT * FROM audit_logs WHERE user_id = $1 ORDER BY timestamp DESC, id DESC', [userId]);
  return rows.map(mapAudit);
}

export async function listAuditLogsByUser(userId: number): Promise<AuditLog[]> {
  return listMyAuditLogs(userId);
}

export async function createAuditLog(entry: {
  userId?: number | null;
  action: string;
  resource: string;
  resourceId?: string | null;
  outcome: AuditOutcome;
  denyReason?: string | null;
  ipAddress?: string | null;
  userAgent?: string | null;
  requestPath?: string | null;
  metadata?: Record<string, unknown> | null;
}): Promise<AuditLog> {
  const row = await queryOne<DbAuditRow>(
    `INSERT INTO audit_logs (
      user_id, action, resource, resource_id, outcome, deny_reason, ip_address, user_agent, request_path, metadata
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, COALESCE($10::jsonb, '{}'::jsonb))
    RETURNING *`,
    [
      entry.userId ?? null,
      entry.action,
      entry.resource,
      entry.resourceId ?? null,
      entry.outcome,
      entry.denyReason ?? null,
      entry.ipAddress ?? null,
      entry.userAgent ?? null,
      entry.requestPath ?? null,
      entry.metadata ? JSON.stringify(entry.metadata) : null,
    ]
  );
  if (!row) throw new Error('Failed to create audit log');
  return mapAudit(row);
}

export async function auditStats(): Promise<Record<string, number>> {
  const rows = await query<{ outcome: AuditOutcome; count: string }>(
    `SELECT outcome, COUNT(*)::text AS count
     FROM audit_logs
     GROUP BY outcome`
  );
  const stats: Record<string, number> = {
    GRANTED: 0,
    DENIED_ROLE: 0,
    DENIED_RELATIONSHIP: 0,
    DENIED_CONTEXT: 0,
    DENIED_SOD: 0,
    ERROR: 0,
  };
  for (const row of rows) {
    stats[row.outcome] = Number(row.count);
  }
  return stats;
}

export async function countAuditByOutcome(outcome: AuditOutcome): Promise<number> {
  const row = await queryOne<{ count: string }>('SELECT COUNT(*)::text AS count FROM audit_logs WHERE outcome = $1', [outcome]);
  return Number(row?.count ?? '0');
}

export async function getActivePeriod(): Promise<AcademicPeriod | null> {
  const row = await queryOne<{
    id: number;
    name: string;
    start_date: string;
    end_date: string;
    grading_open: string;
    grading_close: string;
    is_active: boolean;
    created_at: string;
  }>('SELECT * FROM academic_periods WHERE is_active = TRUE ORDER BY id DESC LIMIT 1');
  return row ? mapPeriod(row) : null;
}

export async function listPeriods(): Promise<AcademicPeriod[]> {
  const rows = await query<{
    id: number;
    name: string;
    start_date: string;
    end_date: string;
    grading_open: string;
    grading_close: string;
    is_active: boolean;
    created_at: string;
  }>('SELECT * FROM academic_periods ORDER BY id DESC');
  return rows.map(mapPeriod);
}

export async function createPeriod(input: {
  name: string;
  startDate: string;
  endDate: string;
  gradingOpen: string;
  gradingClose: string;
}): Promise<AcademicPeriod> {
  const row = await queryOne<{
    id: number;
    name: string;
    start_date: string;
    end_date: string;
    grading_open: string;
    grading_close: string;
    is_active: boolean;
    created_at: string;
  }>(
    `INSERT INTO academic_periods (name, start_date, end_date, grading_open, grading_close, is_active)
     VALUES ($1, $2, $3, $4, $5, FALSE)
     RETURNING *`,
    [input.name, input.startDate, input.endDate, input.gradingOpen, input.gradingClose]
  );
  if (!row) throw new Error('Failed to create period');
  return mapPeriod(row);
}

export async function updatePeriodById(id: number, patch: Partial<{
  name: string;
  startDate: string;
  endDate: string;
  gradingOpen: string;
  gradingClose: string;
  isActive: boolean;
}>): Promise<AcademicPeriod | null> {
  const row = await queryOne<{
    id: number;
    name: string;
    start_date: string;
    end_date: string;
    grading_open: string;
    grading_close: string;
    is_active: boolean;
    created_at: string;
  }>(
    `UPDATE academic_periods
     SET name = COALESCE($2, name),
         start_date = COALESCE($3, start_date),
         end_date = COALESCE($4, end_date),
         grading_open = COALESCE($5, grading_open),
         grading_close = COALESCE($6, grading_close),
         is_active = COALESCE($7, is_active)
     WHERE id = $1
     RETURNING *`,
    [id, patch.name ?? null, patch.startDate ?? null, patch.endDate ?? null, patch.gradingOpen ?? null, patch.gradingClose ?? null, typeof patch.isActive === 'boolean' ? patch.isActive : null]
  );
  return row ? mapPeriod(row) : null;
}

export async function activatePeriodById(id: number): Promise<void> {
  await pool.query('UPDATE academic_periods SET is_active = (id = $1)', [id]);
}

export async function getSystemState(): Promise<DbSystemStateRow> {
  const row = await queryOne<{ emergency_lockout_active: boolean; policy_config: PolicyConfig }>(
    'SELECT emergency_lockout_active, policy_config FROM system_state WHERE id = 1'
  );
  return row ?? { emergency_lockout_active: false, policy_config: basePolicyConfig };
}

export async function updatePolicyConfig(policyConfig: PolicyConfig): Promise<PolicyConfig> {
  await pool.query('UPDATE system_state SET policy_config = $1::jsonb WHERE id = 1', [JSON.stringify(policyConfig)]);
  return policyConfig;
}

export async function setEmergencyLockout(active: boolean): Promise<boolean> {
  await pool.query('UPDATE system_state SET emergency_lockout_active = $1 WHERE id = 1', [active]);
  return active;
}

export async function listContextPolicies(): Promise<ContextPolicy[]> {
  const rows = await query<{
    id: number;
    name: string;
    description: string;
    resource: string;
    action: string;
    condition: Record<string, unknown>;
    is_active: boolean;
    created_at: string;
  }>('SELECT * FROM context_policies ORDER BY id');
  return rows.map((row) => ({
    id: row.id,
    name: row.name,
    description: row.description,
    resource: row.resource,
    action: row.action,
    condition: row.condition,
    isActive: row.is_active,
    createdAt: new Date(row.created_at).toISOString(),
  }));
}

export async function listSeparationOfDutyLogs(): Promise<SeparationOfDutyLog[]> {
  const rows = await query<{
    id: number;
    user_id: number;
    violation: string;
    attempted: string;
    blocked: boolean;
    timestamp: string;
  }>('SELECT * FROM separation_of_duty_logs ORDER BY timestamp DESC, id DESC');
  return rows.map((row) => ({
    id: row.id,
    userId: row.user_id,
    violation: row.violation,
    attempted: row.attempted,
    blocked: row.blocked,
    timestamp: new Date(row.timestamp).toISOString(),
  }));
}

export async function createSeparationOfDutyLog(entry: {
  userId: number;
  violation: string;
  attempted: string;
  blocked?: boolean;
}): Promise<SeparationOfDutyLog> {
  const row = await queryOne<{
    id: number;
    user_id: number;
    violation: string;
    attempted: string;
    blocked: boolean;
    timestamp: string;
  }>(
    `INSERT INTO separation_of_duty_logs (user_id, violation, attempted, blocked)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [entry.userId, entry.violation, entry.attempted, entry.blocked ?? true]
  );
  if (!row) throw new Error('Failed to create separation of duty log');
  return {
    id: row.id,
    userId: row.user_id,
    violation: row.violation,
    attempted: row.attempted,
    blocked: row.blocked,
    timestamp: new Date(row.timestamp).toISOString(),
  };
}

export async function buildAuthUser(userId: number) {
  const user = await userById(userId);
  if (!user) return null;
  const permissions = await permissionsForRole(user.roleId);
  return {
    id: user.id,
    fullName: `${user.firstName} ${user.lastName}`,
    email: user.email,
    role: (await roleById(user.roleId))?.name ?? 'STUDENT',
    permissions,
    department: user.department,
    officeLocation: user.officeLocation,
    consultationHours: user.consultationHours,
    studentId: user.studentId,
    staffId: user.staffId,
    lastLogin: user.lastLogin,
  };
}

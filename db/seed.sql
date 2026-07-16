-- Demo seed data for the PostgreSQL schema.
-- Run db/schema.sql first.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO roles (name, description) VALUES
  ('ADMINISTRATOR', 'Full system access'),
  ('LECTURER', 'Manages courses and grades'),
  ('STUDENT', 'Views own academic data')
ON CONFLICT (name) DO UPDATE
SET description = EXCLUDED.description;

INSERT INTO permissions (resource, action, description) VALUES
  ('users', 'read', 'Read users'),
  ('users', 'write', 'Manage users'),
  ('courses', 'read', 'Read courses'),
  ('courses', 'write', 'Manage courses'),
  ('enrollments', 'read', 'Read enrollments'),
  ('enrollments', 'write', 'Manage enrollments'),
  ('grades', 'read', 'Read grades'),
  ('grades', 'write', 'Submit grades'),
  ('grades', 'approve', 'Approve grades'),
  ('audit', 'read', 'Read audit logs'),
  ('periods', 'write', 'Manage periods')
ON CONFLICT (resource, action) DO UPDATE
SET description = EXCLUDED.description;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON (
  (r.name = 'ADMINISTRATOR' AND p.resource IN ('users', 'courses', 'enrollments', 'grades', 'audit', 'periods')) OR
  (r.name = 'LECTURER' AND (
    (p.resource = 'courses' AND p.action = 'read') OR
    (p.resource = 'enrollments' AND p.action = 'read') OR
    (p.resource = 'grades' AND p.action IN ('read', 'write')) OR
    (p.resource = 'audit' AND p.action = 'read')
  )) OR
  (r.name = 'STUDENT' AND (
    (p.resource = 'courses' AND p.action = 'read') OR
    (p.resource = 'enrollments' AND p.action = 'read') OR
    (p.resource = 'grades' AND p.action = 'read') OR
    (p.resource = 'audit' AND p.action = 'read')
  ))
)
ON CONFLICT DO NOTHING;

INSERT INTO departments (name, code)
VALUES ('Computer Science', 'CS')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO academic_periods (name, start_date, end_date, grading_open, grading_close, is_active)
SELECT
  'Semester 2, 2025/2026',
  '2026-01-05T00:00:00.000Z',
  '2026-06-30T23:59:59.999Z',
  '2026-05-01T00:00:00.000Z',
  '2026-06-30T23:59:59.999Z',
  TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM academic_periods WHERE name = 'Semester 2, 2025/2026'
);

INSERT INTO academic_periods (name, start_date, end_date, grading_open, grading_close, is_active)
SELECT
  'Semester 1, 2025/2026',
  '2025-08-25T00:00:00.000Z',
  '2025-12-15T23:59:59.999Z',
  '2025-12-01T00:00:00.000Z',
  '2025-12-10T23:59:59.999Z',
  FALSE
WHERE NOT EXISTS (
  SELECT 1 FROM academic_periods WHERE name = 'Semester 1, 2025/2026'
);

INSERT INTO users (
  student_id,
  staff_id,
  first_name,
  last_name,
  email,
  password_hash,
  role_id,
  department,
  is_active,
  failed_logins,
  locked_until,
  last_login
)
VALUES
  (
    NULL,
    'ADM-001',
    'System',
    'Admin',
    'admin@rasac.edu',
    crypt('Admin@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'ADMINISTRATOR'),
    NULL,
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    NULL,
    'LEC-001',
    'Dr. Aris',
    'Thorne',
    'dr.thorne@rasac.edu',
    crypt('Lect@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'LECTURER'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    NULL,
    'LEC-002',
    'Prof.',
    'Mensah',
    'prof.mensah@rasac.edu',
    crypt('Lect@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'LECTURER'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    '11330842',
    NULL,
    'Godsway',
    'Baniba',
    'godsway.baniba@rasac.edu',
    crypt('Stud@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'STUDENT'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    '11450289',
    NULL,
    'Elena',
    'Rodriguez',
    'elena.rodriguez@rasac.edu',
    crypt('Stud@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'STUDENT'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    '11220911',
    NULL,
    'Marcus',
    'Thorne',
    'marcus.thorne@rasac.edu',
    crypt('Stud@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'STUDENT'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    '11330755',
    NULL,
    'Liam',
    'O''Connor',
    'liam.oconnor@rasac.edu',
    crypt('Stud@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'STUDENT'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  ),
  (
    '11440822',
    NULL,
    'Sarah',
    'Jenkins',
    'sarah.jenkins@rasac.edu',
    crypt('Stud@123', gen_salt('bf')),
    (SELECT id FROM roles WHERE name = 'STUDENT'),
    'Computer Science',
    TRUE,
    0,
    NULL,
    NULL
  )
ON CONFLICT (email) DO UPDATE
SET
  student_id = EXCLUDED.student_id,
  staff_id = EXCLUDED.staff_id,
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id,
  department = EXCLUDED.department,
  is_active = EXCLUDED.is_active,
  failed_logins = EXCLUDED.failed_logins,
  locked_until = EXCLUDED.locked_until,
  last_login = EXCLUDED.last_login,
  updated_at = NOW();

INSERT INTO courses (code, title, credits, department_id, lecturer_id, academic_period_id, is_active)
VALUES
  (
    'CS-401',
    'Advanced Cryptography & RASAC',
    4,
    (SELECT id FROM departments WHERE code = 'CS'),
    (SELECT id FROM users WHERE email = 'dr.thorne@rasac.edu'),
    (SELECT id FROM academic_periods WHERE name = 'Semester 2, 2025/2026'),
    TRUE
  ),
  (
    'CS302',
    'Database Systems',
    3,
    (SELECT id FROM departments WHERE code = 'CS'),
    (SELECT id FROM users WHERE email = 'dr.thorne@rasac.edu'),
    (SELECT id FROM academic_periods WHERE name = 'Semester 2, 2025/2026'),
    TRUE
  ),
  (
    'CS201',
    'Data Structures',
    3,
    (SELECT id FROM departments WHERE code = 'CS'),
    (SELECT id FROM users WHERE email = 'prof.mensah@rasac.edu'),
    (SELECT id FROM academic_periods WHERE name = 'Semester 2, 2025/2026'),
    TRUE
  )
ON CONFLICT (code) DO UPDATE
SET
  title = EXCLUDED.title,
  credits = EXCLUDED.credits,
  department_id = EXCLUDED.department_id,
  lecturer_id = EXCLUDED.lecturer_id,
  academic_period_id = EXCLUDED.academic_period_id,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

INSERT INTO enrollments (student_id, course_id, enrolled_at, status)
VALUES
  ((SELECT id FROM users WHERE email = 'godsway.baniba@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS-401'), '2024-09-12T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'godsway.baniba@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS302'), '2024-09-12T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'elena.rodriguez@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS-401'), '2024-09-14T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'elena.rodriguez@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS201'), '2024-09-14T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'marcus.thorne@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS-401'), '2024-09-10T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'marcus.thorne@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS302'), '2024-09-10T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'liam.oconnor@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS-401'), '2024-09-12T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'liam.oconnor@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS201'), '2024-09-12T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'sarah.jenkins@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS-401'), '2024-09-13T00:00:00.000Z', 'ACTIVE'),
  ((SELECT id FROM users WHERE email = 'sarah.jenkins@rasac.edu'), (SELECT id FROM courses WHERE code = 'CS302'), '2024-09-13T00:00:00.000Z', 'ACTIVE')
ON CONFLICT (student_id, course_id) DO UPDATE
SET enrolled_at = EXCLUDED.enrolled_at,
    status = EXCLUDED.status;

INSERT INTO grades (
  student_id,
  course_id,
  submitter_id,
  approver_id,
  score,
  grade,
  remarks,
  status,
  submitted_at,
  approved_at
)
VALUES (
  (SELECT id FROM users WHERE email = 'godsway.baniba@rasac.edu'),
  (SELECT id FROM courses WHERE code = 'CS-401'),
  (SELECT id FROM users WHERE email = 'dr.thorne@rasac.edu'),
  NULL,
  94,
  'A',
  'Excellent work',
  'DRAFT',
  NOW(),
  NULL
)
ON CONFLICT (student_id, course_id) DO UPDATE
SET
  submitter_id = EXCLUDED.submitter_id,
  approver_id = EXCLUDED.approver_id,
  score = EXCLUDED.score,
  grade = EXCLUDED.grade,
  remarks = EXCLUDED.remarks,
  status = EXCLUDED.status,
  submitted_at = EXCLUDED.submitted_at,
  approved_at = EXCLUDED.approved_at;

INSERT INTO context_policies (name, description, resource, action, condition, is_active)
VALUES (
  'GradingWindow',
  'Grades may only be submitted while grading is open',
  'grades',
  'write',
  '{"requiresActivePeriod": true, "allowedHours": [0, 23]}'::jsonb,
  TRUE
)
ON CONFLICT (name) DO UPDATE
SET
  description = EXCLUDED.description,
  resource = EXCLUDED.resource,
  action = EXCLUDED.action,
  condition = EXCLUDED.condition,
  is_active = EXCLUDED.is_active;

INSERT INTO system_state (id, emergency_lockout_active, policy_config)
VALUES (
  1,
  FALSE,
  '{
    "matrix": {
      "ADMINISTRATOR": { "read": true, "write": true, "delete": true, "approve": true },
      "LECTURER": { "read": true, "write": true, "delete": false, "approve": true },
      "STUDENT": { "read": true, "write": false, "delete": false, "approve": false }
    },
    "associations": {
      "enrolledInCourse": { "strengthThreshold": 85, "timeoutMins": 120, "isActive": true },
      "assignedLecturer": { "verificationDepth": "Direct Assignment", "reauthCycle": "24h", "isActive": true }
    },
    "environmental": {
      "ipRanges": ["10.0.0.0/8", "192.168.1.0/24"],
      "timeWindow": { "start": "08:00", "end": "18:00", "blockOutside": true },
      "gradingPeriod": { "requiredPeriod": "FINAL_EXAM_PERIOD", "daysLeft": 14 }
    }
  }'::jsonb
)
ON CONFLICT (id) DO UPDATE
SET
  emergency_lockout_active = EXCLUDED.emergency_lockout_active,
  policy_config = EXCLUDED.policy_config;

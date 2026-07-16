# RASAC: Relationship-Aware Secure Access Control

RASAC is a tri-layer authorization demo for higher education systems. Every protected action is evaluated across:

1. Role
2. Relationship
3. Context

If any layer fails, access is denied and logged.

## System Architecture

```text
React UI
  -> fetch API client
  -> Express app
     -> authenticate middleware
     -> authorize middleware
     -> access decision engine
        -> role validator
        -> relationship validator
        -> context evaluator
        -> separation of duty checker
     -> audit logger
     -> in-memory demo store
```

This repository also includes the full Prisma schema requested in `server/prisma/schema.prisma` for database-backed deployments.

## Setup

### Docker

```bash
docker compose up -d
```

### Manual

```bash
npm install
npm run dev
```

The root workspace runs both the server and client if the workspace scripts are present.

## Environment Variables

### Server

See [`server/.env.example`](./server/.env.example).

| Variable | Purpose |
| --- | --- |
| `PORT` | API port |
| `CLIENT_ORIGIN` | Allowed browser origin |
| `JWT_SECRET` | JWT signing secret |
| `ACCESS_TOKEN_TTL` | Access token lifetime |
| `REFRESH_TOKEN_TTL` | Refresh token lifetime |
| `DATABASE_URL` | Prisma database URL |

### Client

See [`client/.env.example`](./client/.env.example).

| Variable | Purpose |
| --- | --- |
| `VITE_API_BASE_URL` | Base URL for API requests |

## API Summary

Base URL: `/api/v1`

### Auth

- `POST /auth/login`
- `POST /auth/logout`
- `POST /auth/refresh`
- `GET /auth/me`
- `POST /auth/change-password`

### Users

- `GET /users`
- `POST /users`
- `GET /users/:id`
- `PATCH /users/:id`
- `DELETE /users/:id`
- `POST /users/:id/lock`
- `POST /users/:id/unlock`

### Courses

- `GET /courses`
- `POST /courses`
- `GET /courses/:id`
- `GET /courses/:id/students`
- `GET /courses/:id/grades`

### Enrollments

- `GET /enrollments/my`
- `POST /enrollments`
- `DELETE /enrollments/:id`
- `GET /enrollments/course/:courseId`

### Grades

- `GET /grades/my`
- `GET /grades/course/:courseId`
- `POST /grades`
- `PATCH /grades/:id`
- `POST /grades/:id/submit`
- `POST /grades/:id/approve`
- `POST /grades/:id/reject`

### Audit

- `GET /audit`
- `GET /audit/stats`
- `GET /audit/user/:userId`
- `GET /audit/my`

### Periods

- `GET /periods`
- `POST /periods`
- `GET /periods/active`
- `PATCH /periods/:id`
- `POST /periods/:id/activate`

### Admin

- `GET /admin/stats`
- `GET /admin/security-events`
- `GET /admin/access-matrix`

## Example curl

```bash
curl -X POST http://localhost:4000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@rasac.edu","password":"Admin@123"}'
```

## Access Decision Engine

### Role layer

Checks whether the user role can perform the requested action on the requested resource.

### Relationship layer

Checks the academic connection between the actor and the target resource:

- lecturer assigned to the course
- student enrolled in the course
- student accessing only their own records

### Context layer

Checks server-side conditions such as:

- active academic period
- open grading window
- configured context policies

### Separation of duty

Runs after the three layers pass and blocks conflicting actions such as:

- same lecturer submitting and approving a grade
- lecturer enrolling themselves into their own course
- students modifying grades

## Test Credentials

- `admin@rasac.edu` / `Admin@123`
- `dr.asante@rasac.edu` / `Lect@123`
- `prof.mensah@rasac.edu` / `Lect@123`
- `godsway.baniba@rasac.edu` / `Stud@123`
- `kwame.asante@rasac.edu` / `Stud@123`
- `abena.mensah@rasac.edu` / `Stud@123`

## Demonstration Scenarios

### 1. Role denial

1. Sign in as a student.
2. Request `GET /api/v1/users`.
3. The request is denied at the role layer.

### 2. Relationship denial

1. Sign in as `dr.asante@rasac.edu`.
2. Request grades for `CS201`.
3. The request is denied because the lecturer is not assigned to that course.

### 3. Context denial

1. Sign in as `dr.asante@rasac.edu`.
2. Attempt grade submission outside the grading window.
3. The request is denied by the context layer.

### 4. SoD enforcement

1. Submit a grade as the lecturer.
2. Attempt approval by the same submitter.
3. The request is denied by the separation-of-duty check.

### 5. All layers pass

1. Sign in as `dr.asante@rasac.edu`.
2. Access a student enrolled in the lecturer's assigned course during an active grading period.
3. The request is granted and logged.

## Security Features

- bcrypt password hashing
- JWT access token and refresh token flow
- httpOnly refresh cookie
- account lockout after five failures
- server-side authorization checks
- audit logging for every protected request
- request size limits
- helmet and CORS protections

## Technology Justification

- React and Express keep the stack approachable for a final-year demonstration.
- JWT + refresh sessions model real-world authentication.
- A tri-layer access engine shows how RBAC can be extended safely.
- An audit trail makes denials and approvals observable for security review.

## RBAC vs RASAC

| Scenario | Traditional RBAC | RASAC Framework |
| --- | --- | --- |
| Lecturer accesses any student's grades | Granted | Denied without enrollment relationship |
| Grade submission outside grading period | Granted | Denied by context |
| Same person submits and approves grade | Granted | Denied by SoD |
| Student views another student's grades | Denied | Denied by role plus relationship |
| Lecturer views own students' grades | Granted | Granted |

## Notes

The current implementation uses an in-memory demo store so the application works immediately in this workspace. The included Prisma schema and seed script document the intended PostgreSQL model for a database-backed deployment.


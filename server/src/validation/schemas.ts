import { z } from 'zod';

/**
 * Central request-validation schemas (§3.7 Input Design).
 * Each schema validates { body, params, query } as passed in by the
 * `validate` middleware (server/src/middleware/validate.ts).
 */

export const loginSchema = z.object({
  body: z.object({
    email: z.string().trim().toLowerCase().email('A valid email address is required'),
    password: z.string().min(1, 'Password is required'),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const changePasswordSchema = z.object({
  body: z.object({
    currentPassword: z.string().min(1, 'Current password is required'),
    newPassword: z
      .string()
      .min(8, 'New password must be at least 8 characters')
      .regex(/[A-Z]/, 'New password must contain an uppercase letter')
      .regex(/[0-9]/, 'New password must contain a number'),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const createUserSchema = z.object({
  body: z.object({
    firstName: z.string().trim().min(1, 'First name is required').max(80),
    lastName: z.string().trim().min(1, 'Last name is required').max(80),
    email: z.string().trim().toLowerCase().email('A valid email address is required'),
    password: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .regex(/[A-Z]/, 'Password must contain an uppercase letter')
      .regex(/[0-9]/, 'Password must contain a number'),
    roleId: z.coerce.number().int().positive('roleId must be a positive integer'),
    studentId: z.string().trim().max(30).optional(),
    staffId: z.string().trim().max(30).optional(),
    department: z.string().trim().max(120).optional(),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const updateUserSchema = z.object({
  body: z.object({
    firstName: z.string().trim().min(1).max(80).optional(),
    lastName: z.string().trim().min(1).max(80).optional(),
    department: z.string().trim().max(120).optional(),
    roleId: z.coerce.number().int().positive().optional(),
    isActive: z.boolean().optional(),
  }),
  params: z.object({
    id: z.coerce.number().int().positive(),
  }),
  query: z.object({}).optional(),
});

export const createCourseSchema = z.object({
  body: z.object({
    code: z
      .string()
      .trim()
      .min(2, 'Course code is required')
      .max(15)
      .regex(/^[A-Za-z0-9\- ]+$/, 'Course code may only contain letters, numbers, spaces and hyphens'),
    title: z.string().trim().min(1, 'Course title is required').max(200),
    credits: z.coerce.number().int().min(1).max(12).optional(),
    departmentId: z.coerce.number().int().positive('departmentId must be a positive integer'),
    lecturerId: z.coerce.number().int().positive('lecturerId must be a positive integer'),
    academicPeriodId: z.coerce.number().int().positive('academicPeriodId must be a positive integer'),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const createGradeSchema = z.object({
  body: z.object({
    studentId: z.coerce.number().int().positive('studentId must be a positive integer'),
    courseId: z.coerce.number().int().positive('courseId must be a positive integer'),
    score: z.coerce.number().min(0, 'Score cannot be negative').max(100, 'Score cannot exceed 100'),
    remarks: z.string().trim().max(500).optional(),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const updateGradeSchema = z.object({
  body: z.object({
    score: z.coerce.number().min(0, 'Score cannot be negative').max(100, 'Score cannot exceed 100').optional(),
    remarks: z.string().trim().max(500).optional(),
  }),
  params: z.object({
    id: z.coerce.number().int().positive(),
  }),
  query: z.object({}).optional(),
});

export const createEnrollmentSchema = z.object({
  body: z.object({
    studentId: z.coerce.number().int().positive('studentId must be a positive integer'),
    courseId: z.coerce.number().int().positive('courseId must be a positive integer'),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

const isoDate = z.string().refine((value) => !Number.isNaN(Date.parse(value)), 'Must be a valid date');

export const createPeriodSchema = z.object({
  body: z
    .object({
      name: z.string().trim().min(1, 'Period name is required').max(120),
      startDate: isoDate,
      endDate: isoDate,
      gradingOpen: isoDate,
      gradingClose: isoDate,
    })
    .refine((data) => Date.parse(data.endDate) > Date.parse(data.startDate), {
      message: 'endDate must be after startDate',
      path: ['endDate'],
    })
    .refine((data) => Date.parse(data.gradingClose) > Date.parse(data.gradingOpen), {
      message: 'gradingClose must be after gradingOpen',
      path: ['gradingClose'],
    }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const updatePeriodSchema = z.object({
  body: z.object({
    name: z.string().trim().min(1).max(120).optional(),
    startDate: isoDate.optional(),
    endDate: isoDate.optional(),
    gradingOpen: isoDate.optional(),
    gradingClose: isoDate.optional(),
  }),
  params: z.object({
    id: z.coerce.number().int().positive(),
  }),
  query: z.object({}).optional(),
});

export const updateAccessMatrixSchema = z.object({
  body: z.object({
    policyConfig: z.object({
      matrix: z.record(
        z.string(),
        z.object({
          read: z.boolean(),
          write: z.boolean(),
          delete: z.boolean(),
          approve: z.boolean(),
        })
      ),
      associations: z.record(z.string(), z.any()).optional(),
      environmental: z.record(z.string(), z.any()).optional(),
    }),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

export const emergencyLockoutSchema = z.object({
  body: z.object({
    active: z.boolean(),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});
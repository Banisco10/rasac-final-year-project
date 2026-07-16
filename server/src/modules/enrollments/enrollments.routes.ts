import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import { validate } from '../../middleware/validate.js';
import { createEnrollmentSchema } from '../../validation/schemas.js';
import {
  getMyEnrollments,
  createEnrollment,
  dropEnrollment,
  getCourseEnrollments,
} from './enrollments.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/my',
  authorize({
    resource: 'enrollments',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetStudentId: req.auth!.userId,
    }),
  }),
  getMyEnrollments
);

router.post(
  '/',
  authorize({
    resource: 'enrollments',
    action: 'write',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetStudentId: Number(req.body.studentId),
      targetCourseId: Number(req.body.courseId),
    }),
    resourceId: (req) => String(req.body.courseId),
  }),
  validate(createEnrollmentSchema),
  createEnrollment
);

router.delete(
  '/:id',
  authorize({
    resource: 'enrollments',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  dropEnrollment
);

router.get(
  '/course/:courseId',
  authorize({
    resource: 'enrollments',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.courseId),
    }),
    resourceId: (req) => String(req.params.courseId),
  }),
  getCourseEnrollments
);

export default router;

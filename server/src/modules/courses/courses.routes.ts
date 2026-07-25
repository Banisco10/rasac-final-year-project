import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import {
  getCourses,
  getCourse,
  createCourse,
  getCourseStudents,
  getCourseGrades,
  getMyGradingProgress,
} from './courses.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/',
  authorize({
    resource: 'courses',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getCourses
);

router.get(
  '/:id',
  authorize({
    resource: 'courses',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.id),
    }),
    resourceId: (req) => String(req.params.id),
  }),
  getCourse
);

router.post(
  '/',
  authorize({
    resource: 'courses',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  createCourse
);

router.get(
  '/:id/students',
  authorize({
    resource: 'students',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.id),
    }),
    resourceId: (req) => String(req.params.id),
  }),
  getCourseStudents
);

router.get(
  '/:id/grades',
  authorize({
    resource: 'grades',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.id),
    }),
    resourceId: (req) => String(req.params.id),
  }),
  getCourseGrades
);

router.get(
  '/my/grading-progress',
  authorize({
    resource: 'courses',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getMyGradingProgress
);

export default router;

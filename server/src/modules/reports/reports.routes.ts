import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import { studentPerformanceReport, courseReport, enrollmentSummary } from './reports.controller.js';

const router = Router();

router.use(authenticate);

// Student performance report — self, or a lecturer scoped to a course they teach
// via ?courseId=, or an administrator.
router.get(
  '/student-performance/:studentId',
  authorize({
    resource: 'reports',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetStudentId: Number(req.params.studentId),
      targetCourseId: req.query.courseId ? Number(req.query.courseId) : undefined,
    }),
    resourceId: (req) => String(req.params.studentId),
  }),
  studentPerformanceReport
);

// Course report — the assigned lecturer, or an administrator.
router.get(
  '/course/:courseId',
  authorize({
    resource: 'reports',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.courseId),
    }),
    resourceId: (req) => String(req.params.courseId),
  }),
  courseReport
);

// Enrollment summary — scoped to one course for lecturers/students, unscoped
// (all courses) for administrators only.
router.get(
  '/enrollment-summary',
  authorize({
    resource: 'reports',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: req.query.courseId ? Number(req.query.courseId) : undefined,
    }),
    resourceId: (req) => (req.query.courseId ? String(req.query.courseId) : 'all-courses'),
  }),
  enrollmentSummary
);

export default router;
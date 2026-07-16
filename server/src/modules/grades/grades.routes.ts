import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import { getGradeById } from '../../data/repository.js';
import {
  getMyGrades,
  getMyTranscript,
  getCourseGrades,
  createGradeRecord,
  updateGradeRecord,
  submitGradeRecord,
  approveGradeRecord,
  rejectGradeRecord,
} from './grades.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/my',
  authorize({
    resource: 'grades',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetStudentId: req.auth!.userId,
    }),
  }),
  getMyGrades
);

router.get(
  '/transcript',
  authorize({
    resource: 'grades',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetStudentId: req.auth!.userId,
    }),
  }),
  getMyTranscript
);

router.get(
  '/course/:courseId',
  authorize({
    resource: 'grades',
    action: 'read',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.params.courseId),
    }),
    resourceId: (req) => String(req.params.courseId),
  }),
  getCourseGrades
);

router.post(
  '/',
  authorize({
    resource: 'grades',
    action: 'write',
    getContext: (req) => ({
      timestamp: new Date(),
      ipAddress: req.ip ?? '',
      targetCourseId: Number(req.body.courseId),
      targetStudentId: Number(req.body.studentId),
    }),
    resourceId: (req) => String(req.body.courseId),
  }),
  createGradeRecord
);

router.patch(
  '/:id',
  authorize({
    resource: 'grades',
    action: 'modify',
    getContext: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return {
        timestamp: new Date(),
        ipAddress: req.ip ?? '',
        targetCourseId: grade?.courseId,
        targetStudentId: grade?.studentId,
      };
    },
    resourceId: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return grade ? String(grade.courseId) : undefined;
    },
  }),
  updateGradeRecord
);

router.post(
  '/:id/submit',
  authorize({
    resource: 'grades',
    action: 'submit',
    getContext: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return {
        timestamp: new Date(),
        ipAddress: req.ip ?? '',
        targetCourseId: grade?.courseId,
        targetStudentId: grade?.studentId,
      };
    },
    resourceId: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return grade ? String(grade.courseId) : undefined;
    },
  }),
  submitGradeRecord
);

router.post(
  '/:id/approve',
  authorize({
    resource: 'grades',
    action: 'approve',
    getContext: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return {
        timestamp: new Date(),
        ipAddress: req.ip ?? '',
        targetCourseId: grade?.courseId,
        targetStudentId: grade?.studentId,
      };
    },
    resourceId: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return grade ? String(grade.courseId) : undefined;
    },
  }),
  approveGradeRecord
);

router.post(
  '/:id/reject',
  authorize({
    resource: 'grades',
    action: 'approve',
    getContext: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return {
        timestamp: new Date(),
        ipAddress: req.ip ?? '',
        targetCourseId: grade?.courseId,
        targetStudentId: grade?.studentId,
      };
    },
    resourceId: async (req) => {
      const grade = await getGradeById(Number(req.params.id));
      return grade ? String(grade.courseId) : undefined;
    },
  }),
  rejectGradeRecord
);

export default router;

import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import { validate } from '../../middleware/validate.js';
import { updateAccessMatrixSchema, emergencyLockoutSchema } from '../../validation/schemas.js';
import {
  getAdminStats,
  getSecurityEvents,
  getAccessMatrix,
  updateAccessMatrix,
  toggleEmergencyLockout,
  getGradeApprovalQueue,
} from './admin.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/stats',
  authorize({
    resource: 'users',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getAdminStats
);

router.get(
  '/security-events',
  authorize({
    resource: 'audit',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getSecurityEvents
);

router.get(
  '/grades/pending',
  authorize({
    resource: 'grades',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getGradeApprovalQueue
);

router.get(
  '/access-matrix',
  authorize({
    resource: 'users',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getAccessMatrix
);

router.post(
  '/access-matrix',
  authorize({
    resource: 'periods',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  validate(updateAccessMatrixSchema),
  updateAccessMatrix
);

router.post(
  '/emergency-lockout',
  authorize({
    resource: 'periods',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  validate(emergencyLockoutSchema),
  toggleEmergencyLockout
);

export default router;

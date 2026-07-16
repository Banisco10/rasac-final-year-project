import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import { validate } from '../../middleware/validate.js';
import { createPeriodSchema, updatePeriodSchema } from '../../validation/schemas.js';
import {
  getPeriods,
  createPeriod,
  getActivePeriod,
  updatePeriod,
  activatePeriod,
} from './periods.controller.js';

const router = Router();

// /active does not require specialized 'periods' resource permission, just login authentication
router.get('/active', authenticate, getActivePeriod);

router.use(authenticate);

router.get(
  '/',
  authorize({
    resource: 'periods',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getPeriods
);

router.post(
  '/',
  authorize({
    resource: 'periods',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  validate(createPeriodSchema),
  createPeriod
);

router.patch(
  '/:id',
  authorize({
    resource: 'periods',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  validate(updatePeriodSchema),
  updatePeriod
);

router.post(
  '/:id/activate',
  authorize({
    resource: 'periods',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  activatePeriod
);

export default router;

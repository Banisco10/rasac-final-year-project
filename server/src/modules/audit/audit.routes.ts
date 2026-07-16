import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import {
  getAllAuditLogs,
  getAuditStats,
  getUserAuditLogs,
  getMyAuditLogs,
} from './audit.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/',
  authorize({
    resource: 'audit',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getAllAuditLogs
);

router.get(
  '/stats',
  authorize({
    resource: 'audit',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getAuditStats
);

router.get(
  '/user/:userId',
  authorize({
    resource: 'audit',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getUserAuditLogs
);

router.get('/my', getMyAuditLogs);

export default router;

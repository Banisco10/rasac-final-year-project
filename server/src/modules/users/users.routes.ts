import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authorize } from '../../middleware/authorize.js';
import {
  getUsers,
  createUserController,
  getUser,
  updateUser,
  deleteUser,
  lockUser,
  unlockUser,
  updateMyContactInfo,
} from './users.controller.js';

const router = Router();

router.use(authenticate);

router.get(
  '/',
  authorize({
    resource: 'users',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getUsers
);

router.post(
  '/',
  authorize({
    resource: 'users',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  createUserController
);

router.patch(
  '/me/contact',
  authorize({
    resource: 'my-profile',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  updateMyContactInfo
);

router.get(
  '/:id',
  authorize({
    resource: 'users',
    action: 'read',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  getUser
);

router.patch(
  '/:id',
  authorize({
    resource: 'users',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  updateUser
);

router.delete(
  '/:id',
  authorize({
    resource: 'users',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  deleteUser
);

router.post(
  '/:id/lock',
  authorize({
    resource: 'users',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  lockUser
);

router.post(
  '/:id/unlock',
  authorize({
    resource: 'users',
    action: 'write',
    getContext: (req) => ({ timestamp: new Date(), ipAddress: req.ip ?? '' }),
  }),
  unlockUser
);

export default router;

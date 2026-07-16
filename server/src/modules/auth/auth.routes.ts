import { Router } from 'express';
import { authRateLimiter } from '../../middleware/rateLimiter.js';
import { authenticate } from '../../middleware/authenticate.js';
import {
  login,
  logout,
  refresh,
  me,
  changePassword,
} from './auth.controller.js';

const router = Router();

router.post('/login', authRateLimiter, login);
router.post('/logout', authenticate, logout);
router.post('/refresh', refresh);
router.get('/me', authenticate, me);
router.post('/change-password', authenticate, changePassword);

export default router;

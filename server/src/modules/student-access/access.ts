import { Router } from 'express';
import type { Response } from 'express';
import { accessDecisionEngine } from '../../engines/accessDecisionEngine.js';
import { authenticate, AuthenticatedRequest } from '../../middleware/authenticate.js';
import type { RoleName } from '../../../../shared/types.js';

const router = Router();

// POST /api/v1/access/simulate
// Runs a hypothetical request through the real tri-layer engine and returns
// the full TracedDecision. userId/userRole/timestamp/ipAddress always come
// from the authenticated session - never trust those from the body. The
// target fields (resourceId, targetStudentId, targetCourseId) come from the
// client because the whole point is to probe scenarios that may not
// correspond to a real record.
router.post('/simulate', authenticate, async (req: AuthenticatedRequest, res: Response) => {
  const { resource, action, resourceId, context } = req.body as {
    resource?: string;
    action?: string;
    resourceId?: string;
    context?: {
      targetStudentId?: number;
      targetCourseId?: number;
      academicPeriodId?: number;
    };
  };

  if (!resource || !action) {
    return res.status(400).json({ error: 'resource and action are required' });
  }

  if (!req.auth) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const decision = await accessDecisionEngine.evaluate({
    userId: req.auth.userId,
    userRole: req.auth.role as RoleName,
    resource,
    action,
    resourceId,
    context: {
      timestamp: new Date(),
      ipAddress: req.ip ?? 'unknown',
      ...context,
    },
  });

  return res.status(200).json(decision);
});

export default router;
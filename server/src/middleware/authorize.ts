import { NextFunction, Response } from 'express';
import { AccessContext, RoleCode } from '../types.js';
import { accessDecisionEngine } from '../engines/accessDecisionEngine.js';
import { AuthenticatedRequest } from './authenticate.js';

export interface AuthorizationOptions {
  resource: string;
  action: string;
  getContext: (req: AuthenticatedRequest) => AccessContext | Promise<AccessContext>;
  resourceId?: (req: AuthenticatedRequest) => string | undefined | Promise<string | undefined>;
}

export function authorize(options: AuthorizationOptions) {
  return async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    if (!req.auth) {
      res.status(401).json({ success: false, code: 'SESSION_EXPIRED', message: 'Authentication required' });
      return;
    }
    const context = await options.getContext(req);
    context.requestPath = req.originalUrl;
    console.log('AUTHORIZE MIDDLEWARE SET PATH:', context.requestPath, 'for', options.resource, options.action);


    const decision = await accessDecisionEngine.evaluate({
      userId: req.auth.userId,
      userRole: req.auth.role as RoleCode,
      resource: options.resource,
      action: options.action,
      resourceId: await options.resourceId?.(req),
      context,
    });
    if (!decision.granted) {
      res.status(403).json({
        success: false,
        code: decision.denyReason ?? 'INSUFFICIENT_ROLE',
        message: decision.layerFailed === 'ROLE'
          ? 'Access denied by role layer'
          : decision.layerFailed === 'RELATIONSHIP'
            ? 'Access denied by relationship layer'
            : decision.layerFailed === 'CONTEXT'
              ? 'Access denied by context layer'
              : 'Access denied by separation of duty',
      });
      return;
    }
    next();
  };
}

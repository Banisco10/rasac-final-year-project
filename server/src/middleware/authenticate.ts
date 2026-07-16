import { NextFunction, Request, Response } from 'express';
import { verifyToken } from '../utils/jwt.js';
import { auditLogger } from '../utils/auditLogger.js';
import { getSessionById, userById, roleById } from '../data/repository.js';

export interface AuthenticatedRequest extends Request {
  auth?: {
    userId: number;
    sessionId: string;
    role: string;
  };
}

function extractBearer(tokenHeader?: string): string | null {
  if (!tokenHeader) return null;
  const [scheme, token] = tokenHeader.split(' ');
  return scheme === 'Bearer' && token ? token : null;
}

export async function authenticate(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
  const token = extractBearer(req.headers.authorization);
  if (!token) {
    res.status(401).json({ success: false, code: 'SESSION_EXPIRED', message: 'Authentication required' });
    return;
  }

  try {
    const payload = verifyToken(token);
    const session = await getSessionById(payload.sid);
    const user = await userById(payload.sub);
    const role = user ? await roleById(user.roleId) : null;
    if (!session || session.isRevoked || !user || !user.isActive || !role) {
      await auditLogger.log({
        userId: payload.sub,
        action: 'AUTH_CHECK',
        resource: 'sessions',
        outcome: 'DENIED_ROLE',
        denyReason: 'SESSION_EXPIRED',
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'],
        requestPath: req.path,
      });
      res.status(401).json({ success: false, code: 'SESSION_EXPIRED', message: 'Session expired or revoked' });
      return;
    }
    req.auth = { userId: payload.sub, sessionId: payload.sid, role: role.name };
    next();
  } catch {
    res.status(401).json({ success: false, code: 'SESSION_EXPIRED', message: 'Invalid session' });
  }
}

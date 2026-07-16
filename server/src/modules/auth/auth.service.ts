import express from 'express';
import { randomUUID } from 'crypto';
import { parseCookies } from '../../utils/http.js';
import {
  buildAuthUser,
  createSession,
  getSessionByRefreshToken,
  permissionsForRole,
  roleById,
  userById,
} from '../../data/repository.js';
import { signRefreshToken } from '../../utils/jwt.js';
import type { RoleName } from '../../../../shared/types.js';

export { buildAuthUser, permissionsForRole };

export function readRefreshToken(req: express.Request): string | null {
  const cookies = parseCookies(req.headers.cookie);
  if (cookies.refreshToken) return cookies.refreshToken;
  if (typeof req.body?.refreshToken === 'string') return req.body.refreshToken;
  return null;
}

export async function issueSession(userId: number, role: string, req: express.Request) {
  const sessionId = cryptoRandomId();
  const refreshToken = signRefreshToken({ sub: userId, sid: sessionId, role: role as RoleName });
  await createSession({
    userId,
    sessionId,
    refreshToken,
    ipAddress: req.ip ?? '',
    userAgent: req.headers['user-agent'] ?? '',
  });
  return {
    sessionId,
    refreshToken,
  };
}

export async function validateRefreshToken(refreshToken: string) {
  const session = await getSessionByRefreshToken(refreshToken);
  if (!session) return null;
  const user = await userById(session.userId);
  if (!user || !user.isActive) return null;
  const role = await roleById(user.roleId);
  if (!role) return null;
  return { user, role, session };
}

function cryptoRandomId(): string {
  return randomUUID();
}

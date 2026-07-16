import bcrypt from 'bcryptjs';
import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { sendError, sendSuccess } from '../../utils/response.js';
import { buildCookie } from '../../utils/http.js';
import { signAccessToken, verifyToken } from '../../utils/jwt.js';
import {
  getSessionByRefreshToken,
  revokeSession,
  revokeUserSessions,
  updateUserById,
  userByEmail,
  userById,
  roleById,
} from '../../data/repository.js';
import { issueSession, readRefreshToken } from './auth.service.js';
import { buildAuthUser } from '../../data/repository.js';

export async function login(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { email, password, rememberMe } = req.body as { email?: string; password?: string; rememberMe?: boolean };
  if (!email || !password) {
    sendError(res, 400, 'VALIDATION_ERROR', 'Email and password are required');
    return;
  }

  const user = await userByEmail(email);
  if (!user || !user.isActive) {
    sendError(res, 401, 'INVALID_CREDENTIALS', 'Invalid email or password');
    return;
  }
  if (user.lockedUntil && new Date(user.lockedUntil).getTime() > Date.now()) {
    sendError(res, 423, 'ACCOUNT_LOCKED', `Account locked until ${user.lockedUntil}`);
    return;
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    await updateUserById(user.id, {
      failedLogins: user.failedLogins + 1,
      lockedUntil: user.failedLogins + 1 >= 5 ? new Date(Date.now() + 30 * 60 * 1000).toISOString() : user.lockedUntil,
    });
    sendError(res, 401, 'INVALID_CREDENTIALS', 'Invalid email or password');
    return;
  }

  const normalizeIp = (raw: string | undefined | null): string | null => {
    if (!raw) return null;
    if (raw === '::1') return '127.0.0.1';
    if (raw.startsWith('::ffff:')) return raw.slice(7);
    return raw;
  };

  const previousLogin = {
    lastLogin: user.lastLogin ?? null,
    ipAddress: normalizeIp(user.lastLoginIp),
  };

  const currentIp = normalizeIp(req.ip);

  await updateUserById(user.id, {
    failedLogins: 0,
    lockedUntil: null,
    lastLogin: new Date().toISOString(),
    lastLoginIp: currentIp,
  });

  const role = (await roleById(user.roleId))?.name ?? 'STUDENT';
  const { sessionId, refreshToken } = await issueSession(user.id, role, req);
  const accessToken = signAccessToken({ sub: user.id, sid: sessionId, role });
  const cookieMaxAge = rememberMe ? 7 * 24 * 60 * 60 : undefined;
  res.setHeader('Set-Cookie', buildCookie('refreshToken', refreshToken, cookieMaxAge));
  sendSuccess(res, {
    accessToken,
    refreshToken,
    user: await buildAuthUser(user.id),
    previousLogin,
  });
}

export async function logout(req: AuthenticatedRequest, res: Response): Promise<void> {
  const refreshToken = readRefreshToken(req);
  if (refreshToken) {
    await revokeSession(refreshToken);
  }
  res.setHeader('Set-Cookie', buildCookie('refreshToken', '', 0));
  sendSuccess(res, { loggedOut: true });
}

export async function refresh(req: AuthenticatedRequest, res: Response): Promise<void> {
  const refreshToken = readRefreshToken(req);
  if (!refreshToken) {
    sendError(res, 401, 'SESSION_EXPIRED', 'Refresh token missing');
    return;
  }
  try {
    const payload = verifyToken(refreshToken);
    const session = await getSessionByRefreshToken(refreshToken);
    const user = await userById(payload.sub);
    const role = user ? await roleById(user.roleId) : null;
    if (!session || !user || !role || !user.isActive || session.id !== payload.sid || session.isRevoked) {
      sendError(res, 401, 'SESSION_EXPIRED', 'Refresh token invalid');
      return;
    }
    const accessToken = signAccessToken({
      sub: user.id,
      sid: session.id,
      role: role.name,
    });
    sendSuccess(res, { accessToken });
  } catch {
    sendError(res, 401, 'SESSION_EXPIRED', 'Refresh token invalid');
  }
}

export async function me(req: AuthenticatedRequest, res: Response): Promise<void> {
  const user = await buildAuthUser(req.auth!.userId);
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  sendSuccess(res, user);
}

export async function changePassword(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { oldPassword, newPassword } = req.body as { oldPassword?: string; newPassword?: string };
  if (!oldPassword || !newPassword) {
    sendError(res, 400, 'VALIDATION_ERROR', 'Old and new passwords are required');
    return;
  }
  const user = await userById(req.auth!.userId);
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  const valid = await bcrypt.compare(oldPassword, user.passwordHash);
  if (!valid) {
    sendError(res, 401, 'INVALID_CREDENTIALS', 'Invalid password');
    return;
  }
  await updateUserById(user.id, {
    passwordHash: await bcrypt.hash(newPassword, 12),
  });
  await revokeUserSessions(user.id);
  res.setHeader('Set-Cookie', buildCookie('refreshToken', '', 0));
  sendSuccess(res, { changed: true });
}


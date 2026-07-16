import jwt from 'jsonwebtoken';
import { appEnv } from '../config/env.js';
import { RoleName } from '../../../shared/types.js';

export interface JwtPayload {
  sub: number;
  sid: string;
  role: RoleName;
}

export function signAccessToken(payload: JwtPayload): string {
  return jwt.sign(payload, appEnv.jwtSecret, { expiresIn: appEnv.accessTokenTtl as jwt.SignOptions['expiresIn'] });
}

export function signRefreshToken(payload: JwtPayload): string {
  return jwt.sign(payload, appEnv.jwtSecret, { expiresIn: appEnv.refreshTokenTtl as jwt.SignOptions['expiresIn'] });
}

export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, appEnv.jwtSecret) as any as JwtPayload;
}

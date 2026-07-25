import rateLimit from 'express-rate-limit';
import type { Request, Response } from 'express';

const createRateLimiter = rateLimit as unknown as (options: Record<string, unknown>) => import('express').RequestHandler;

export const generalRateLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 10000,
  skip: () => process.env.NODE_ENV !== 'production',
  handler: (_req: Request, res: Response) => {
    res.status(429).json({
      success: false,
      code: 'RATE_LIMITED',
      message: 'Too many requests, please try again later.',
    });
  },
});

export const authRateLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 10000,
  skip: () => process.env.NODE_ENV !== 'production',
  handler: (_req: Request, res: Response) => {
    res.status(429).json({
      success: false,
      code: 'RATE_LIMITED',
      message: 'Too many login attempts, please try again later.',
    });
  },
});
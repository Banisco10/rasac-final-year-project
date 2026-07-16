import rateLimit from 'express-rate-limit';

export const generalRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10000,
  skip: () => process.env.NODE_ENV !== 'production',
  handler: (_req, res) => {
    res.status(429).json({
      success: false,
      code: 'RATE_LIMITED',
      message: 'Too many requests, please try again later.',
    });
  },
});

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10000,
  skip: () => process.env.NODE_ENV !== 'production',
  handler: (_req, res) => {
    res.status(429).json({
      success: false,
      code: 'RATE_LIMITED',
      message: 'Too many login attempts, please try again later.',
    });
  },
});
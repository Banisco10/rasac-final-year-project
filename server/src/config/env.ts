export interface AppEnv {
  port: number;
  jwtSecret: string;
  accessTokenTtl: string;
  refreshTokenTtl: string;
  clientOrigin: string;
  nodeEnv: string;
  databaseUrl: string;
  jwtExpiresIn: string;
}

const rawEnv = process.env;
console.log("DATABASE_URL FROM VERCEL:", rawEnv.DATABASE_URL);

const accessTokenTtl = rawEnv.ACCESS_TOKEN_TTL ?? rawEnv.JWT_EXPIRES_IN ?? '15m';

export const appEnv: AppEnv = {
  port: Number(rawEnv.PORT ?? 4000),
  jwtSecret: rawEnv.JWT_SECRET ?? 'rasac-dev-secret',
  accessTokenTtl,
  refreshTokenTtl: rawEnv.REFRESH_TOKEN_TTL ?? '7d',
  clientOrigin: rawEnv.CLIENT_ORIGIN ?? rawEnv.CORS_ORIGIN ?? 'http://localhost:5173',
  nodeEnv: rawEnv.NODE_ENV ?? 'development',
  databaseUrl: rawEnv.DATABASE_URL ?? 'postgresql://postgres:postgres123@localhost:5433/rbac_db',
  jwtExpiresIn: accessTokenTtl,
};

export const envConfig = appEnv;
const envVars = {
  databaseUrl: appEnv.databaseUrl,
  jwtSecret: appEnv.jwtSecret,
  accessTokenTtl: appEnv.accessTokenTtl,
  refreshTokenTtl: appEnv.refreshTokenTtl,
  clientOrigin: appEnv.clientOrigin,
  nodeEnv: appEnv.nodeEnv,
};

export { envVars as env };

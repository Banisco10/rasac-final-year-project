// @ts-ignore - pg runtime is installed; the workspace is missing its type package.
import { Pool, types } from 'pg';
import { env } from '../config/env.js';

types.setTypeParser(20, (value: string) => Number.parseInt(value, 10));
types.setTypeParser(1700, (value: string) => Number.parseFloat(value));

export const pool = new Pool({
  connectionString: env.databaseUrl,
  ssl: env.databaseUrl.includes("localhost") ? undefined : { rejectUnauthorized: false }
});

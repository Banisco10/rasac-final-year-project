import dotenv from "dotenv";
dotenv.config();
import app from './app.js';
import { appEnv } from './config/env.js';
import { initializeDatabase } from './data/repository.js';

console.log("DB URL:", appEnv.databaseUrl);
console.log("DATABASE_URL:", process.env.DATABASE_URL);
await initializeDatabase();

app.listen(appEnv.port, () => {
  console.log(JSON.stringify({ level: 'info', message: `RASAC API running on port ${appEnv.port}` }));
});

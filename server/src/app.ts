// @ts-ignore - cors runtime is installed; the workspace is missing its type package.
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { appEnv } from './config/env.js';
import { generalRateLimiter } from './middleware/rateLimiter.js';
import { requestLogger } from './middleware/requestLogger.js';
import { errorHandler } from './middleware/errorHandler.js';


import authRouter from './modules/auth/auth.routes.js';
import usersRouter from './modules/users/users.routes.js';
import coursesRouter from './modules/courses/courses.routes.js';
import enrollmentsRouter from './modules/enrollments/enrollments.routes.js';
import gradesRouter from './modules/grades/grades.routes.js';
import auditRouter from './modules/audit/audit.routes.js';
import adminRouter from './modules/admin/admin.routes.js';
import periodsRouter from './modules/periods/periods.routes.js';
import accessRouter from './modules/student-access/access.js';
import reportsRouter from './modules/reports/reports.routes.js';

const app = express();
app.set('trust proxy', 1);
// app.use(helmet());
app.use((helmet as unknown as () => express.RequestHandler)());
app.use(cors({ origin: appEnv.clientOrigin, credentials: true }));
app.use(express.json({ limit: '10kb' }));
app.use(requestLogger);
app.use(generalRateLimiter);


app.get('/health', (_req, res) => {
  res.status(200).json({ success: true, data: { ok: true } });
});

app.use('/api/v1/auth', authRouter);
app.use('/api/v1/users', usersRouter);
app.use('/api/v1/courses', coursesRouter);
app.use('/api/v1/enrollments', enrollmentsRouter);
app.use('/api/v1/grades', gradesRouter);
app.use('/api/v1/audit', auditRouter);
app.use('/api/v1/admin', adminRouter);
app.use('/api/v1/periods', periodsRouter);
app.use('/api/v1/access', accessRouter);
app.use('/api/v1/reports', reportsRouter);

app.use(errorHandler);

export default app;

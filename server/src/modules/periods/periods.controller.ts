import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { createPeriod as createPeriodRecord, activatePeriodById, getActivePeriod as getActivePeriodRecord, listPeriods, updatePeriodById } from '../../data/repository.js';
import { sendError, sendSuccess } from '../../utils/response.js';

export async function getPeriods(req: AuthenticatedRequest, res: Response): Promise<void> {
  sendSuccess(res, await listPeriods());
}

export async function createPeriod(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { name, startDate, endDate, gradingOpen, gradingClose } = req.body as Record<string, string | undefined>;
  if (!name || !startDate || !endDate || !gradingOpen || !gradingClose) {
    sendError(res, 400, 'VALIDATION_ERROR', 'Missing required fields');
    return;
  }
  sendSuccess(res, await createPeriodRecord({ name, startDate, endDate, gradingOpen, gradingClose }), 201);
}

export async function getActivePeriod(req: AuthenticatedRequest, res: Response): Promise<void> {
  sendSuccess(res, await getActivePeriodRecord());
}

export async function updatePeriod(req: AuthenticatedRequest, res: Response): Promise<void> {
  const period = await updatePeriodById(Number(req.params.id), req.body);
  if (!period) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Period not found');
    return;
  }
  sendSuccess(res, period);
}

export async function activatePeriod(req: AuthenticatedRequest, res: Response): Promise<void> {
  await activatePeriodById(Number(req.params.id));
  sendSuccess(res, { activated: true });
}

import bcrypt from 'bcryptjs';
import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { sendError, sendSuccess } from '../../utils/response.js';
import { buildAuthUser, createUser as createUserRecord, getUserDetail, listUsers, roleById, updateUserById, userById } from '../../data/repository.js';
import { createSeparationOfDutyLog } from '../../data/repository.js';

export async function getUsers(req: AuthenticatedRequest, res: Response): Promise<void> {
  const role = await roleById((await userById(req.auth!.userId))!.roleId);
  const data = await listUsers();
  sendSuccess(res, { data, total: data.length, page: 1, totalPages: 1, viewerRole: role?.name });
}

export async function createUserController(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { firstName, lastName, email, password, roleId, studentId, staffId, department } = req.body as Record<string, string | number | undefined>;
  if (!firstName || !lastName || !email || !password || !roleId) {
    sendError(res, 400, 'VALIDATION_ERROR', 'Missing required fields');
    return;
  }
  if (Number(roleId) !== 3) {
    await createSeparationOfDutyLog({
      userId: req.auth!.userId,
      violation: 'USER_CREATE_ASSIGN',
      attempted: `create-user:${String(email)}`,
      blocked: true,
    });
    sendError(res, 403, 'SEPARATION_OF_DUTY_VIOLATION', 'Assign elevated roles in a separate step');
    return;
  }

  const passwordHash = await bcrypt.hash(String(password), 12);
  const created = await createUserRecord({
    firstName: String(firstName),
    lastName: String(lastName),
    email: String(email),
    passwordHash,
    roleId: Number(roleId),
    studentId: studentId ? String(studentId) : null,
    staffId: staffId ? String(staffId) : null,
    department: department ? String(department) : null,
  });

  sendSuccess(res, { id: created.id });
}

export async function getUser(req: AuthenticatedRequest, res: Response): Promise<void> {
  const userDetail = await getUserDetail(Number(req.params.id));
  if (!userDetail) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  sendSuccess(res, userDetail);
}

export async function updateUser(req: AuthenticatedRequest, res: Response): Promise<void> {
  const user = await userById(Number(req.params.id));
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  if (user.id === req.auth!.userId && req.body.roleId) {
    sendError(res, 403, 'INSUFFICIENT_ROLE', 'You cannot change your own role');
    return;
  }
  await updateUserById(user.id, {
    firstName: req.body.firstName ? String(req.body.firstName) : undefined,
    lastName: req.body.lastName ? String(req.body.lastName) : undefined,
    department: req.body.department ? String(req.body.department) : undefined,
    roleId: req.body.roleId ? Number(req.body.roleId) : undefined,
    isActive: typeof req.body.isActive === 'boolean' ? req.body.isActive : undefined,
  });
  sendSuccess(res, { updated: true });
}

export async function deleteUser(req: AuthenticatedRequest, res: Response): Promise<void> {
  const user = await userById(Number(req.params.id));
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  await updateUserById(user.id, { isActive: false });
  sendSuccess(res, { deleted: true });
}

export async function lockUser(req: AuthenticatedRequest, res: Response): Promise<void> {
  const user = await userById(Number(req.params.id));
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  await updateUserById(user.id, { lockedUntil: new Date(Date.now() + 30 * 60 * 1000).toISOString() });
  sendSuccess(res, { locked: true });
}

export async function unlockUser(req: AuthenticatedRequest, res: Response): Promise<void> {
  const user = await userById(Number(req.params.id));
  if (!user) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'User not found');
    return;
  }
  await updateUserById(user.id, { lockedUntil: null, failedLogins: 0 });
  sendSuccess(res, { unlocked: true });
}

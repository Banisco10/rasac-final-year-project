import type { AccessRequest } from '../../../shared/types.js';
import { getSystemState } from '../data/repository.js';

export async function validateRole(request: AccessRequest): Promise<{ passed: boolean; reason?: string }> {
  const systemState = await getSystemState();
  const matrix = systemState.policy_config.matrix;
  const roleConfig = matrix[request.userRole];

  console.log('DEBUG roleValidator:', {
    userRole: request.userRole,
    action: request.action,
    roleConfig,
    matrixKeys: Object.keys(matrix),
  });
  
  if (!roleConfig) {
    return { passed: false, reason: `Unknown role: ${request.userRole}` };
  }

  const action = request.action;

  if (action === 'read') {
    return { passed: roleConfig.read, reason: roleConfig.read ? undefined : 'Role lacks read access' };
  }
  if (['write', 'submit', 'modify'].includes(action)) {
    return { passed: roleConfig.write, reason: roleConfig.write ? undefined : 'Role lacks write access' };
  }
  if (action === 'delete') {
    return { passed: roleConfig.delete, reason: roleConfig.delete ? undefined : 'Role lacks delete access' };
  }
  if (['approve', 'reject'].includes(action)) {
    return { passed: roleConfig.approve, reason: roleConfig.approve ? undefined : 'Role lacks approval access' };
  }

  return { passed: false, reason: `Action not configured: ${action}` };
}


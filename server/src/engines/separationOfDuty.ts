import type { AccessRequest } from '../../../shared/types.js';
import { courseById, getGradeById } from '../data/repository.js';

export async function checkSeparationOfDuty(request: AccessRequest): Promise<{ passed: boolean; reason?: string }> {
  const { resource, action, userId, userRole, context, resourceId } = request;

  if (userRole === 'ADMINISTRATOR' && request.resource === 'users' && action === 'write') {
    return { passed: true };
  }

  if (resource === 'grades' && action === 'approve') {
    const grade = resourceId ? await getGradeById(Number(resourceId)) : null;
    if (!grade) {
      return { passed: false, reason: 'Grade not found' };
    }
    if (grade.submitterId === userId) {
      return { passed: false, reason: 'Submitter cannot approve own grade' };
    }
  }

  if (resource === 'enrollments' && action === 'write') {
    const course = context.targetCourseId ? await courseById(context.targetCourseId) : null;
    if (userRole === 'LECTURER' && course && course.lecturerId === userId && context.targetStudentId === userId) {
      return { passed: false, reason: 'Lecturer cannot enroll self in own course' };
    }
  }

  if (resource === 'users' && action === 'write') {
    return { passed: true };
  }

  if (resource === 'grades' && action === 'modify' && userRole === 'STUDENT') {
    return { passed: false, reason: 'Student cannot modify grades' };
  }

  if (resourceId && resource === 'grades') {
    const existing = await getGradeById(Number(resourceId));
    if (existing && action === 'write' && existing.submitterId === userId && userRole === 'ADMINISTRATOR') {
      return { passed: false, reason: 'Admin cannot submit own grade' };
    }
  }

  return { passed: true };
}


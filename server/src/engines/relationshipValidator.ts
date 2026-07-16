import type { AccessRequest } from '../../../shared/types.js';
import { courseById, enrollmentsForStudent, enrollmentsForCourse } from '../data/repository.js';

export async function validateRelationship(request: AccessRequest): Promise<{ passed: boolean; reason?: string }> {
  const { resource, action, userId, userRole, context } = request;

  if (userRole === 'ADMINISTRATOR') {
    return { passed: true };
  }

  if (resource === 'courses' && action === 'read') {
    if (!context.targetCourseId) {
      return { passed: true };
    }
    const course = await courseById(context.targetCourseId);
    if (!course) {
      return { passed: false, reason: 'Course not found' };
    }
    if (userRole === 'LECTURER') {
      return { passed: course.lecturerId === userId };
    }
    if (userRole === 'STUDENT') {
      const enrollments = await enrollmentsForStudent(userId);
      const isEnrolled = enrollments.some((enrollment) => enrollment.courseId === course.id);
      return { passed: isEnrolled };
    }
  }

  if (resource === 'students' && action === 'read') {
    if (!context.targetCourseId) {
      return { passed: false, reason: 'Course target missing' };
    }
    const course = await courseById(context.targetCourseId);
    return { passed: Boolean(course && course.lecturerId === userId) };
  }

  if (resource === 'enrollments' && action === 'read') {
    if (userRole === 'STUDENT') {
      return { passed: context.targetStudentId === userId };
    }
    return { passed: true };
  }

  if (resource === 'grades' && action === 'read') {
    if (userRole === 'STUDENT') {
      return { passed: context.targetStudentId === userId };
    }
    if (userRole === 'LECTURER') {
      if (!context.targetCourseId) {
        return { passed: false, reason: 'Course target missing' };
      }
      const course = await courseById(context.targetCourseId);
      return { passed: Boolean(course && course.lecturerId === userId) };
    }
  }

  if (resource === 'grades' && (action === 'write' || action === 'approve' || action === 'submit')) {
    if (!context.targetCourseId) {
      return { passed: false, reason: 'Course target missing' };
    }
    const course = await courseById(context.targetCourseId);
    if (!course) {
      return { passed: false, reason: 'Course not found' };
    }
    if (userRole === 'LECTURER') {
      return { passed: course.lecturerId === userId };
    }
    if (userRole === 'STUDENT') {
      return { passed: context.targetStudentId === userId };
    }
  }

  if (resource === 'reports' && action === 'read') {
  if (context.targetStudentId) {
    if (userRole === 'STUDENT') {
      return { passed: context.targetStudentId === userId };
    }
    if (userRole === 'LECTURER') {
      if (!context.targetCourseId) {
        return { passed: false, reason: 'Course target missing' };
      }
      const course = await courseById(context.targetCourseId);
      if (!course || course.lecturerId !== userId) {
        return { passed: false, reason: 'Not the assigned lecturer for this course' };
      }
      const enrollments = await enrollmentsForCourse(context.targetCourseId);
      const isEnrolled = enrollments.some((enrollment) => enrollment.studentId === context.targetStudentId);
      return { passed: isEnrolled, reason: isEnrolled ? undefined : 'Student is not enrolled in this course' };
    }
    return { passed: false, reason: 'No academic relationship' };
  }

  if (context.targetCourseId) {
    const course = await courseById(context.targetCourseId);
    if (!course) {
      return { passed: false, reason: 'Course not found' };
    }
    if (userRole === 'LECTURER') {
      return { passed: course.lecturerId === userId };
    }
    if (userRole === 'STUDENT') {
      const enrollments = await enrollmentsForStudent(userId);
      return { passed: enrollments.some((enrollment) => enrollment.courseId === course.id) };
    }
  }

  return { passed: false, reason: 'Reports require a course or student scope for non-administrators' };
}

  if (resource === 'audit' && action === 'read') {
    return { passed: true };
  }

  if (resource === 'users' && action === 'read') {
    return { passed: true };
  }

  if (resource === 'periods' && action === 'read') {
    return { passed: true };
  }

  if (resource === 'my-profile') {
    return { passed: true };
  }

  if (resource === 'grades' && userRole === 'STUDENT' && action === 'modify') {
    return { passed: false, reason: 'Student cannot modify grades' };
  }

  return { passed: false, reason: 'No academic relationship' };
}


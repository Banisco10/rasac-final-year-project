import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { createEnrollment as createEnrollmentRecord, dropEnrollmentById, enrollmentsForCourse, enrollmentsForStudent, courseById, userById } from '../../data/repository.js';
import { sendSuccess, sendError } from '../../utils/response.js';

export async function getMyEnrollments(req: AuthenticatedRequest, res: Response): Promise<void> {
  sendSuccess(res, await enrollmentsForStudent(req.auth!.userId));
}

export async function createEnrollment(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { studentId, courseId } = req.body as { studentId?: number; courseId?: number };
  if (!studentId || !courseId) {
    sendError(res, 400, 'VALIDATION_ERROR', 'studentId and courseId are required');
    return;
  }
  const course = await courseById(Number(courseId));
  const student = await userById(Number(studentId));
  if (!course || !student) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Course or student not found');
    return;
  }
  sendSuccess(res, { enrolled: true, enrollment: await createEnrollmentRecord({ studentId: student.id, courseId: course.id }) });
}

export async function dropEnrollment(req: AuthenticatedRequest, res: Response): Promise<void> {
  await dropEnrollmentById(Number(req.params.id));
  sendSuccess(res, { dropped: true });
}

export async function getCourseEnrollments(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseId = Number(req.params.courseId);
  const rows = await enrollmentsForCourse(courseId);
  sendSuccess(res, {
    data: rows,
    total: rows.length,
    page: 1,
    totalPages: 1,
  });
}


import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import {
  buildAuthUser,
  courseById,
  courseStudents,
  createCourse as createCourseRecord,
  listCourses,
  listGradesByCourse,
  userById,
  roleById,
} from '../../data/repository.js';
import { sendError, sendSuccess } from '../../utils/response.js';

export async function getCourses(req: AuthenticatedRequest, res: Response): Promise<void> {
  const viewer = await userById(req.auth!.userId);
  const role = viewer ? (await roleById(viewer.roleId))?.name : null;
  const courses = await listCourses(viewer && role ? { id: viewer.id, role } : undefined);
  sendSuccess(res, { data: courses, total: courses.length, page: 1, totalPages: 1 });
}

export async function getCourse(req: AuthenticatedRequest, res: Response): Promise<void> {
  const course = await courseById(Number(req.params.id));
  if (!course) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Course not found');
    return;
  }
  sendSuccess(res, {
    course,
    lecturer: await buildAuthUser(course.lecturerId),
  });
}

export async function createCourse(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { code, title, credits, departmentId, lecturerId, academicPeriodId } = req.body as Record<string, string | number | undefined>;
  if (!code || !title || !departmentId || !lecturerId || !academicPeriodId) {
    sendError(res, 400, 'VALIDATION_ERROR', 'Missing required fields');
    return;
  }
  sendSuccess(
    res,
    await createCourseRecord({
      code: String(code),
      title: String(title),
      credits: Number(credits ?? 3),
      departmentId: Number(departmentId),
      lecturerId: Number(lecturerId),
      academicPeriodId: Number(academicPeriodId),
    })
  );
}

export async function getCourseStudents(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseId = Number(req.params.id);
  const students = await courseStudents(courseId);
  sendSuccess(res, { data: students, total: students.length, page: 1, totalPages: 1 });
}

export async function getCourseGrades(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseId = Number(req.params.id);
  const grades = await listGradesByCourse(courseId);
  sendSuccess(res, { data: grades, total: grades.length, page: 1, totalPages: 1 });
}


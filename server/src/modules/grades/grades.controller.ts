import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { calculateGrade } from '../../utils/gradeCalculator.js';
import { sendError, sendSuccess } from '../../utils/response.js';
import {
  createGrade as createGradeInDb,
  courseById,
  enrollmentsForStudent,
  getGradeById,
  listGradesByCourse,
  listGradesByStudent,
  listCourses,
  setGradeStatus,
  updateGradeById,
} from '../../data/repository.js';

function scoreToPoints(score: number): number {
  if (score >= 80) return 4;
  if (score >= 75) return 3.5;
  if (score >= 70) return 3.0;
  if (score >= 65) return 2.5;
  if (score >= 60) return 2.0;
  if (score >= 55) return 1.5;
  if (score >= 50) return 1.0;
  if (score >= 45) return 0.5;
  return 0;
}

export async function getMyGrades(req: AuthenticatedRequest, res: Response): Promise<void> {
  const grades = await listGradesByStudent(req.auth!.userId);
  const isStudent = req.auth!.role === 'STUDENT';
  sendSuccess(res, isStudent ? grades.filter((g) => g.status === 'APPROVED') : grades);
}

export async function getCourseGrades(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseId = Number(req.params.courseId);
  sendSuccess(res, await listGradesByCourse(courseId));
}

export async function createGradeRecord(req: AuthenticatedRequest, res: Response): Promise<void> {
  const { studentId, courseId, score, remarks } = req.body as Record<string, number | string | undefined>;
  if (!studentId || !courseId || typeof score !== 'number') {
    sendError(res, 400, 'VALIDATION_ERROR', 'studentId, courseId and score are required');
    return;
  }
  sendSuccess(
    res,
    await createGradeInDb({
      studentId: Number(studentId),
      courseId: Number(courseId),
      submitterId: req.auth!.userId,
      score: Number(score),
      grade: calculateGrade(Number(score)),
      remarks: remarks ? String(remarks) : null,
    }),
    201
  );
}

export async function updateGradeRecord(req: AuthenticatedRequest, res: Response): Promise<void> {
  const grade = await getGradeById(Number(req.params.id));
  if (!grade) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Grade not found');
    return;
  }
  if (grade.submitterId !== req.auth!.userId) {
    sendError(res, 403, 'NO_ACADEMIC_RELATIONSHIP', 'Only the submitter can update the draft');
    return;
  }
  const updated = await updateGradeById(grade.id, {
    score: typeof req.body.score === 'number' ? req.body.score : undefined,
    grade: typeof req.body.score === 'number' ? calculateGrade(req.body.score) : grade.grade,
    remarks: req.body.remarks ?? grade.remarks,
  });
  sendSuccess(res, updated ?? grade);
}

export async function submitGradeRecord(req: AuthenticatedRequest, res: Response): Promise<void> {
  const grade = await getGradeById(Number(req.params.id));
  if (!grade) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Grade not found');
    return;
  }
  if (grade.submitterId !== req.auth!.userId) {
    sendError(res, 403, 'NO_ACADEMIC_RELATIONSHIP', 'Only the submitter can submit the grade');
    return;
  }
  sendSuccess(res, await setGradeStatus(grade.id, 'SUBMITTED') ?? grade);
}

export async function approveGradeRecord(req: AuthenticatedRequest, res: Response): Promise<void> {
  const grade = await getGradeById(Number(req.params.id));
  if (!grade) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Grade not found');
    return;
  }
  sendSuccess(res, await setGradeStatus(grade.id, 'APPROVED', req.auth!.userId) ?? grade);
}

export async function rejectGradeRecord(req: AuthenticatedRequest, res: Response): Promise<void> {
  const grade = await getGradeById(Number(req.params.id));
  if (!grade) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Grade not found');
    return;
  }
  sendSuccess(res, await setGradeStatus(grade.id, 'REJECTED') ?? grade);
}

export async function getMyTranscript(req: AuthenticatedRequest, res: Response): Promise<void> {
  const allGrades = await listGradesByStudent(req.auth!.userId);
  const isStudent = req.auth!.role === 'STUDENT';
  const grades = isStudent ? allGrades.filter((g) => g.status === 'APPROVED') : allGrades;
  const courses = await listCourses();
  const courseMap = new Map(courses.map((course) => [course.id, course]));
  const enrollments = await enrollmentsForStudent(req.auth!.userId);
  const totalCredits = enrollments.reduce((sum, enrollment) => sum + (courseMap.get(enrollment.courseId)?.credits ?? 3), 0);
  const gradePoints = grades.reduce((sum, grade) => sum + scoreToPoints(grade.score) * (courseMap.get(grade.courseId)?.credits ?? 3), 0);
  const gpa = totalCredits > 0 ? Number((gradePoints / totalCredits).toFixed(2)) : 0;
  sendSuccess(res, {
    studentId: req.auth!.userId,
    gpa,
    totalCredits,
    grades: grades.map((grade) => ({
      ...grade,
      course: courseMap.get(grade.courseId) ?? null,
    })),
  });
}

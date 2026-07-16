import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/authenticate.js';
import { sendError, sendSuccess } from '../../utils/response.js';
import {
  courseById,
  courseStudents,
  enrollmentsForCourse,
  listCourses,
  listGradesByCourse,
  listGradesByStudent,
  userById,
} from '../../data/repository.js';

function average(values: number[]): number | null {
  if (values.length === 0) return null;
  return Math.round((values.reduce((sum, value) => sum + value, 0) / values.length) * 100) / 100;
}

function toCsv(rows: Record<string, unknown>[]): string {
  if (rows.length === 0) return '';
  const headers = Object.keys(rows[0]);
  const escape = (value: unknown) => {
    const text = value === null || value === undefined ? '' : String(value);
    return /[",\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
  };
  const lines = [headers.join(',')];
  for (const row of rows) {
    lines.push(headers.map((header) => escape(row[header])).join(','));
  }
  return lines.join('\n');
}

function sendCsvOrJson(res: Response, filename: string, rows: Record<string, unknown>[], summary: Record<string, unknown>): void {
  if (res.req.query.format === 'csv') {
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.status(200).send(toCsv(rows));
    return;
  }
  sendSuccess(res, { summary, rows });
}

/**
 * GET /reports/student-performance/:studentId
 * §3.8.2 Academic Reports — "Student performance reports"
 * Access: student (self only), lecturer (only for students enrolled in one of their
 * courses, scoped via ?courseId=), administrator (any student).
 */
export async function studentPerformanceReport(req: AuthenticatedRequest, res: Response): Promise<void> {
  const studentId = Number(req.params.studentId);
  const student = await userById(studentId);
  if (!student) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Student not found');
    return;
  }

  const grades = await listGradesByStudent(studentId);
  const courses = await listCourses();
  const courseMap = new Map(courses.map((course) => [course.id, course]));

  const rows = grades.map((grade) => {
    const course = courseMap.get(grade.courseId);
    return {
      courseCode: course?.code ?? `#${grade.courseId}`,
      courseTitle: course?.title ?? 'Unknown course',
      score: grade.score,
      grade: grade.grade,
      status: grade.status,
      submittedAt: grade.submittedAt,
      approvedAt: grade.approvedAt ?? '',
    };
  });

  const approvedScores = grades.filter((grade) => grade.status === 'APPROVED').map((grade) => grade.score);

  const summary = {
    studentId: student.id,
    studentName: `${student.firstName} ${student.lastName}`,
    studentIdentifier: student.studentId,
    department: student.department,
    coursesGraded: grades.length,
    coursesApproved: approvedScores.length,
    averageScore: average(approvedScores),
    generatedAt: new Date().toISOString(),
  };

  sendCsvOrJson(res, `student-performance-${studentId}.csv`, rows, summary);
}

/**
 * GET /reports/course/:courseId
 * §3.8.2 Academic Reports — "Course reports"
 * Access: lecturer (own course only), administrator (any course).
 */
export async function courseReport(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseId = Number(req.params.courseId);
  const course = await courseById(courseId);
  if (!course) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Course not found');
    return;
  }

  const grades = await listGradesByCourse(courseId);
  const enrollments = await enrollmentsForCourse(courseId);

  const rows = grades.map((grade) => ({
    studentId: grade.studentId,
    score: grade.score,
    grade: grade.grade,
    status: grade.status,
    submittedAt: grade.submittedAt,
    approvedAt: grade.approvedAt ?? '',
  }));

  const approvedScores = grades.filter((grade) => grade.status === 'APPROVED').map((grade) => grade.score);
  const distribution: Record<string, number> = {};
  for (const grade of grades.filter((g) => g.status === 'APPROVED')) {
    distribution[grade.grade] = (distribution[grade.grade] ?? 0) + 1;
  }

  const summary = {
    courseId: course.id,
    courseCode: course.code,
    courseTitle: course.title,
    enrolledStudents: enrollments.length,
    gradesRecorded: grades.length,
    gradesApproved: approvedScores.length,
    averageScore: average(approvedScores),
    passCount: approvedScores.filter((score) => score >= 50).length,
    failCount: approvedScores.filter((score) => score < 50).length,
    gradeDistribution: distribution,
    generatedAt: new Date().toISOString(),
  };

  sendCsvOrJson(res, `course-report-${course.code}.csv`, rows, summary);
}

/**
 * GET /reports/enrollment-summary
 * §3.8.2 Academic Reports — "Enrollment summaries"
 * Access: administrator sees all courses; lecturer sees only their own courses
 * (?courseId= is required for lecturers, enforced at the relationship layer).
 */
export async function enrollmentSummary(req: AuthenticatedRequest, res: Response): Promise<void> {
  const courseIdParam = req.query.courseId ? Number(req.query.courseId) : undefined;

  const courses = courseIdParam
    ? [await courseById(courseIdParam)].filter((c): c is NonNullable<typeof c> => c !== null)
    : await listCourses();

  if (courseIdParam && courses.length === 0) {
    sendError(res, 404, 'RESOURCE_NOT_FOUND', 'Course not found');
    return;
  }

  const rows = [];
  for (const course of courses) {
    const enrollments = await enrollmentsForCourse(course.id);
    const students = await courseStudents(course.id);
    rows.push({
      courseCode: course.code,
      courseTitle: course.title,
      enrolledCount: enrollments.length,
      activeStudents: students.filter((s) => s.isActive).length,
    });
  }

  const summary = {
    coursesCovered: rows.length,
    totalEnrollments: rows.reduce((sum, row) => sum + row.enrolledCount, 0),
    generatedAt: new Date().toISOString(),
  };

  sendCsvOrJson(res, 'enrollment-summary.csv', rows, summary);
}
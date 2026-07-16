import { buildAuthUser, enrollmentsForStudent, listGradesByStudent, listCourses } from '../../data/repository.js';
import { courseById, listUsers as listDbUsers, userById } from '../../data/repository.js';

export async function getAllUsers() {
  return listDbUsers();
}

export async function createUser(data: {
  firstName: string;
  lastName: string;
  email: string;
  passwordHash: string;
  roleId: number;
  studentId?: string | null;
  staffId?: string | null;
  department?: string | null;
}) {
  throw new Error('createUser should be called through controller with repository');
}

export async function getUserDetail(id: number) {
  const user = await userById(id);
  if (!user) return null;
  return {
    ...(await buildAuthUser(user.id)),
    isActive: user.isActive,
    academicAssociations: {
      lecturedCourses: (await listCourses()).filter((course) => course.lecturerId === user.id),
      enrollments: await enrollmentsForStudent(user.id),
      gradesSubmitted: (await listGradesByStudent(user.id)).filter((grade) => grade.submitterId === user.id),
    },
  };
}


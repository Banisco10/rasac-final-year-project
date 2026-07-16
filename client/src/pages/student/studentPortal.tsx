import { BookOpen, Award, History, CircleHelp, LayoutDashboard } from 'lucide-react';
import type { NavItem } from '../../types';

export const studentSidebarItems: NavItem[] = [
  { view: 'student-dashboard', label: 'Overview', icon: <LayoutDashboard size={20} /> },
  { view: 'student-courses', label: 'Courses', icon: <BookOpen size={20} /> },
  { view: 'student-grades', label: 'Grades', icon: <Award size={20} /> },
  { view: 'student-activity', label: 'Activity', icon: <History size={20} /> },
  { view: 'student-support', label: 'Support', icon: <CircleHelp size={20} /> },
];

export function getStudentInitials(fullName?: string | null) {
  return fullName
    ? fullName
        .split(' ')
        .map((part) => part[0])
        .join('')
        .slice(0, 2)
        .toUpperCase()
    : 'ST';
}

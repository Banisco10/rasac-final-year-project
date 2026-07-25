export * from '../../shared/types';

import type React from 'react';

export type View =
  | 'login'
  | 'dashboard'
  | 'lecturer-dashboard'
  | 'lecturer-activity'
  | 'lecturer-profile'
  | 'lecturer-grading'
  | 'student-dashboard'
  | 'student-courses'
  | 'student-grades'
  | 'student-activity'
  | 'student-support'
  | 'course-detail'
  | 'access-control'
  | 'audit-logs'
  | 'user-management'
  | 'system-settings';

export type NavItem = {
  view: View;
  label: string;
  icon: React.ReactNode;
};

export type PortalChoice = 'dashboard' | 'lecturer-dashboard' | 'student-dashboard';

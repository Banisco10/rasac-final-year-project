import { useEffect, useRef, useState } from 'react';
import { api, setAccessToken, hasStoredToken } from './api';
import type { View } from './types';
import type { PreviousLoginInfo } from '../../shared/types';


// Page imports
import { LoginScreen } from './pages/Login';
import { DashboardHomeScreen } from './pages/admin/DashboardHome';
import { LecturerDashboardScreen } from './pages/lecturer/LecturerDashboard';
import { LecturerActivityScreen } from './pages/lecturer/LecturerActivity';
import { LecturerProfileScreen } from './pages/lecturer/LecturerProfile';
import { LecturerGradingPortalScreen } from './pages/lecturer/LecturerGradingPortal';
import { StudentDashboardScreen } from './pages/student/StudentDashboard';
import { StudentCoursesScreen } from './pages/student/StudentCourses';
import { StudentGradesScreen } from './pages/student/StudentGrades';
import { StudentActivityScreen } from './pages/student/StudentActivity';
import { StudentSupportScreen } from './pages/student/StudentSupport';
import { AccessControlScreen } from './pages/admin/AccessControl';
import { AuditLogsScreen } from './pages/admin/AuditLogs';
import { UserManagementScreen } from './pages/admin/UserManagement';
import { CourseDetailScreen } from './pages/admin/CourseDetail';
import { SystemSettingsScreen } from './pages/admin/SystemSettings';


const ROLE_VIEWS: Record<string, View[]> = {
  ADMINISTRATOR: ['dashboard', 'access-control', 'audit-logs', 'user-management', 'system-settings', 'course-detail'],
  LECTURER: ['lecturer-dashboard', 'lecturer-activity', 'lecturer-profile', 'lecturer-grading'],
  STUDENT: ['student-dashboard', 'student-courses', 'student-grades', 'student-activity', 'student-support'],
};

function isAllowed(view: View, role: string | null): boolean {
  if (view === 'login') return true;
  if (!role) return false;
  return ROLE_VIEWS[role]?.includes(view) ?? false;
}

function useHashView(canAccess: (v: View) => boolean): [View, (next: View, params?: Record<string, string>) => void] {
  const parse = (): View => {
    const raw = window.location.hash.replace('#', '').split('?')[0];
    const known: View[] = [
      'dashboard', 'lecturer-dashboard', 'lecturer-activity', 'lecturer-profile',
      'lecturer-grading', 'student-dashboard', 'student-courses', 'student-grades',
      'student-activity', 'student-support', 'course-detail', 'access-control',
      'audit-logs', 'user-management', 'system-settings', 'login',
    ];
    return (known as string[]).includes(raw) ? (raw as View) : 'login';
  };

  const [view, setView] = useState<View>(parse);
  const viewRef = useRef(view);
  viewRef.current = view;

    useEffect(() => {
    const onHashChange = () => {
      const next = parse();
      if (canAccess(next)) {
        setView(next);
      } else {
        // block: snap the URL back, stay on current screen
        window.location.hash = viewRef.current;
      }
    };
    window.addEventListener('hashchange', onHashChange);
    return () => window.removeEventListener('hashchange', onHashChange);
  }, [canAccess]);

  const go = (next: View, params?: Record<string, string>) => {
    if (!canAccess(next)) return;
    const query = params ? `?${new URLSearchParams(params).toString()}` : '';
    window.location.hash = next + query;
    setView(next);
  };

  return [view, go];
}


function App() {
  const [role, setRole] = useState<string | null>(null);
  const [authChecked, setAuthChecked] = useState(false);
  const [signedIn, setSignedIn] = useState(hasStoredToken());
  const [previousLogin, setPreviousLogin] = useState<PreviousLoginInfo | null>(null);

  const [view, go] = useHashView((v) => isAllowed(v, role));


  useEffect(() => {
    if (!window.location.hash) window.location.hash = 'login';
  }, []);

  useEffect(() => {
    if (!hasStoredToken()) {
      setAuthChecked(true);
      return;
    }
    api.me()
      .then((user) => {
        setRole(user.role);
        setSignedIn(true);
      })
      .catch(() => {
        setAccessToken(null);
        setSignedIn(false);
      })
      .finally(() => setAuthChecked(true));
  }, []);


  useEffect(() => {
    if (!authChecked) return;
    if (view !== 'login' && !isAllowed(view, role)) {
      window.location.hash = signedIn ? '' : 'login';
      if (!signedIn) go('login');
      else {
        const fallback = role === 'ADMINISTRATOR' ? 'dashboard'
          : role === 'LECTURER' ? 'lecturer-dashboard' : 'student-dashboard';
        go(fallback as View);
      }
    }
  }, [authChecked]);

  const handleLogout = () => {
    setAccessToken(null);
    setSignedIn(false);
    setRole(null);
    setPreviousLogin(null);
    go('login');
  };


  const handleLoginSuccess = (userRole: string, prevLogin?: PreviousLoginInfo | null) => {
    setSignedIn(true);
    setRole(userRole);
    setPreviousLogin(prevLogin ?? null);
    setTimeout(() => {
      if (userRole === 'ADMINISTRATOR') go('dashboard');
      else if (userRole === 'LECTURER') go('lecturer-dashboard');
      else go('student-dashboard');
    }, 50);
  };

  if (view === 'login') {
    return <LoginScreen onEnter={handleLoginSuccess} />;
  }

  if (view === 'dashboard') {
    return <DashboardHomeScreen signedIn={signedIn} previousLogin={previousLogin} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'lecturer-dashboard') {
    return <LecturerDashboardScreen signedIn={signedIn} previousLogin={previousLogin} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'lecturer-activity') {
    return <LecturerActivityScreen signedIn={signedIn} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'lecturer-profile') {
    return <LecturerProfileScreen signedIn={signedIn} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'lecturer-grading') {
    return <LecturerGradingPortalScreen signedIn={signedIn} activeView={view} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'student-dashboard') {
    return <StudentDashboardScreen signedIn={signedIn} activeView={view} previousLogin={previousLogin} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'student-courses') {
    return <StudentCoursesScreen signedIn={signedIn} activeView={view} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'student-grades') {
    return <StudentGradesScreen signedIn={signedIn} activeView={view} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'student-activity') {
    return <StudentActivityScreen signedIn={signedIn} activeView={view} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'student-support') {
    return <StudentSupportScreen signedIn={signedIn} activeView={view} onNavigate={go} onLogout={() => { setSignedIn(false); go('login'); }} />;
  }

  if (view === 'access-control') {
    return <AccessControlScreen signedIn={signedIn} onNavigate={go} onLogout={handleLogout} />;
  }

  if (view === 'audit-logs') {
    return <AuditLogsScreen signedIn={signedIn} onNavigate={go} onLogout={handleLogout} />;
  }

  if (view === 'user-management') {
    return <UserManagementScreen signedIn={signedIn} onNavigate={go} onLogout={handleLogout} />;
  }

  if (view === 'system-settings') {
    return <SystemSettingsScreen signedIn={signedIn} onNavigate={go} onLogout={handleLogout} />;
  }

  return <CourseDetailScreen signedIn={signedIn} onNavigate={go} onLogout={handleLogout} />;
}

export default App;

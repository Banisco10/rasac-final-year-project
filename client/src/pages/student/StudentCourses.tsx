import { useEffect, useMemo, useState } from 'react';
import {
  Bell,
  BookOpen,
  ChevronRight,
  GraduationCap,
  Monitor,
  RefreshCcw,
  Settings,
  Shield,
  CalendarDays,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, Course, Enrollment, AuthenticatedUser, AcademicPeriod } from '../../types';
import { api } from '../../api';
import { getStudentInitials, studentSidebarItems } from './studentPortal';

function formatDate(value?: string | null) {
  return value ? new Date(value).toLocaleDateString() : '--';
}

export function StudentCoursesScreen({
  activeView,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  activeView: View;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.courses().then((response) => setCourses(response.data)).catch(console.error);
    api.myEnrollments().then(setEnrollments).catch(console.error);
    api.activePeriod().then(setActivePeriod).catch(console.error);
  }, []);

  const enrolledCourseIds = useMemo(
    () => Array.from(new Set(enrollments.map((enrollment) => enrollment.courseId))),
    [enrollments],
  );

  const displayName = me?.fullName ?? 'Student';
  const initials = getStudentInitials(displayName);
  const enrolledCount = enrolledCourseIds.length;
  const totalCredits = courses
    .filter((course) => enrolledCourseIds.includes(course.id))
    .reduce((sum, course) => sum + course.credits, 0);
  const loading = !me || !courses.length;

  const filteredCourses = courses
    .filter((course) => enrolledCourseIds.includes(course.id))
    .sort((a, b) => a.code.localeCompare(b.code));

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT ACADEMICS"
      searchPlaceholder="Search courses..."
      sidebarItems={studentSidebarItems}
      footerAction={() => onNavigate('student-grades')}
      footerActionClassName="deploy-btn"
      footerActionLabel="View Grades"
      footerActionIcon={<GraduationCap size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Student' }}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications"><Bell size={20} /></button>
          <button className="icon-chip" aria-label="Console"><Monitor size={20} /></button>
          <button className="icon-chip" aria-label="Settings"><Settings size={20} /></button>
          <div className="student-user-chip" aria-label="Student profile">
            <div className="student-user-copy">
              <strong>{displayName.toUpperCase()}</strong>
              <span>STUDENT</span>
            </div>
            <div className="student-user-avatar">{initials}</div>
          </div>
        </>
      }
      topbarClassName="student-main"
      shellClassName="student-shell student-shell--courses"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-page student-courses-page">
        <header className="student-page-hero student-hero-courses">
          <div>
            <div className="student-page-kicker">COURSE ATLAS</div>
            <h1>My Courses</h1>
            <p>
              A clean map of the modules you are enrolled in, the lecturers attached to each class,
              and how many peers are currently in the room with you.
            </p>
          </div>
          <div className="student-page-hero-badge">
            <span>ACTIVE PERIOD</span>
            <strong>{activePeriod?.name ?? 'No active period'}</strong>
          </div>
        </header>

        <div className="student-insight-grid">
          <article className="student-insight-card">
            <span>ENROLLED MODULES</span>
            <strong>{enrolledCount}</strong>
            <p>Courses on your current timetable.</p>
          </article>
          <article className="student-insight-card">
            <span>TOTAL CREDITS</span>
            <strong>{totalCredits || enrollments.length * 3}</strong>
            <p>Credits currently in progress.</p>
          </article>
          <article className="student-insight-card">
            <span>COURSE LOAD</span>
            <strong>{filteredCourses.length}</strong>
            <p>Modules visible in your current schedule.</p>
          </article>
          <article className="student-insight-card accent">
            <span>SESSION STATUS</span>
            <strong>{loading ? 'SYNCING' : 'READY'}</strong>
            <p>{loading ? 'Loading your course map...' : 'Courses and enrollments are synced from the academic backend.'}</p>
          </article>
        </div>

        <section className="student-courses-layout">
          <div className="panel-card student-atlas-card">
            <div className="panel-heading student-panel-heading">
              <div className="section-inline">
                <BookOpen size={18} />
                <h3>ENROLLED COURSES</h3>
              </div>
              <button className="view-btn" type="button" onClick={() => api.myEnrollments().then(setEnrollments).catch(console.error)}>
                <RefreshCcw size={16} />
                Refresh
              </button>
            </div>

            <div className="student-course-tiles">
              {filteredCourses.length === 0 && (
                <div className="student-empty-state">
                  <strong>No courses found.</strong>
                  <p>Your enrollment list is empty or still loading.</p>
                </div>
              )}

              {filteredCourses.map((course) => {
                return (
                  <article className="student-course-tile" key={course.id}>
                    <div className="student-course-tile-top">
                      <div>
                        <div className="student-course-code">{course.code}</div>
                        <h4>{course.title}</h4>
                      </div>
                      <span className="student-course-credit">{course.credits} CR</span>
                    </div>
                    <div className="student-course-meta">
                      <span>
                        <CalendarDays size={14} />
                        Period {formatDate(activePeriod?.startDate)} to {formatDate(activePeriod?.endDate)}
                      </span>
                      <span>
                        <Shield size={14} />
                        Enrollment ID {enrollments.find((entry) => entry.courseId === course.id)?.id ?? '--'}
                      </span>
                      <span>
                        <GraduationCap size={14} />
                        Registered for {course.credits} credits
                      </span>
                    </div>
                    <div className="student-course-actions">
                      <button className="primary-mini" type="button" onClick={() => onNavigate('student-grades')}>
                        View Grades
                      </button>
                      <button className="outlined-btn" type="button" onClick={() => onNavigate('student-support')}>
                        Ask for Help <ChevronRight size={16} />
                      </button>
                    </div>
                  </article>
                );
              })}
            </div>
          </div>

          <aside className="panel-card student-course-sidebar">
            <div className="panel-heading">
              <h3>COURSE SNAPSHOT</h3>
              <Shield size={18} />
            </div>
            <div className="student-snapshot-list">
              {filteredCourses.slice(0, 4).map((course) => (
                <div className="student-snapshot-item" key={course.id}>
                  <strong>{course.code}</strong>
                  <span>{course.title}</span>
                  <p>{course.credits} credits | Enrollment #{enrollments.find((entry) => entry.courseId === course.id)?.id ?? '--'}</p>
                </div>
              ))}
              {filteredCourses.length === 0 && (
                <p style={{ color: 'var(--muted)', margin: 0 }}>Open your enrollments to see course details here.</p>
              )}
            </div>
          </aside>
        </section>
      </section>
    </Shell>
  );
}

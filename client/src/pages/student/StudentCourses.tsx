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
import { Modal } from '../../components/Modal';

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
  const [search, setSearch] = useState('');
  const [meLoaded, setMeLoaded] = useState(false);
  const [coursesLoaded, setCoursesLoaded] = useState(false);
  const [enrollmentsLoaded, setEnrollmentsLoaded] = useState(false);
  const [periodLoaded, setPeriodLoaded] = useState(false);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [loadErrors, setLoadErrors] = useState<string[]>([]);
  const [refreshing, setRefreshing] = useState(false);

const loadData = () => {
  setRefreshing(true);
  setLoadErrors([]);

  Promise.allSettled([
    api.me().then(setMe).catch(() => setLoadErrors((prev) => [...prev, 'profile'])).finally(() => setMeLoaded(true)),
    api.courses().then((response) => setCourses(response.data)).catch(() => setLoadErrors((prev) => [...prev, 'course catalog'])).finally(() => setCoursesLoaded(true)),
    api.myEnrollments().then(setEnrollments).catch(() => setLoadErrors((prev) => [...prev, 'enrollments'])).finally(() => setEnrollmentsLoaded(true)),
    api.activePeriod().then(setActivePeriod).catch(() => setLoadErrors((prev) => [...prev, 'academic period'])).finally(() => setPeriodLoaded(true)),
  ]).finally(() => setRefreshing(false));
};

useEffect(() => {
  loadData();
}, []);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

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
  const loading = !(meLoaded && coursesLoaded && enrollmentsLoaded && periodLoaded);

  const filteredCourses = courses
    .filter((course) => enrolledCourseIds.includes(course.id))
    .filter((course) => {
      if (!search.trim()) return true;
      const term = search.toLowerCase();
      return (
        course.code.toLowerCase().includes(term) ||
        course.title.toLowerCase().includes(term) ||
        String(course.credits).includes(term)
      );
    })
    .sort((a, b) => a.code.localeCompare(b.code));

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT ACADEMICS"
      searchPlaceholder="Search courses..."
      searchValue={search}
      onSearchChange={setSearch}
      sidebarItems={studentSidebarItems}
      footerAction={() => onNavigate('student-grades')}
      footerActionClassName="deploy-btn"
      footerActionLabel="View Grades"
      footerActionIcon={<GraduationCap size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.role ?? 'STUDENT' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            aria-label="Notifications"
            onClick={() => openNotice('Notifications', `You are enrolled in ${enrolledCount} course${enrolledCount === 1 ? '' : 's'} this period.`)}
          >
            <Bell size={20} />
          </button>
          <button
            className="icon-chip"
            aria-label="Console"
            onClick={() => openNotice('Console Status', `Active period: ${activePeriod?.name ?? 'None'}. ${filteredCourses.length} course${filteredCourses.length === 1 ? '' : 's'} currently visible.`)}
          >
            <Monitor size={20} />
          </button>
          <button
            className="icon-chip"
            aria-label="Settings"
            onClick={() => openNotice('Settings', `Department: ${me?.department ?? 'Not set'}`)}
          >
            <Settings size={20} />
          </button>
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
          {loadErrors.length > 0 && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '16px',
              padding: '14px 18px',
              borderRadius: '8px',
              border: '1px solid var(--danger, #b91c1c)',
              background: 'var(--panel, rgba(255,255,255,0.03))',
            }}
          >
            <div>
              <strong style={{ color: 'var(--text)' }}>Some information couldn't load</strong>
              <p style={{ color: 'var(--muted)', margin: '2px 0 0', fontSize: '13px' }}>
                We had trouble loading your {loadErrors.join(', ')}. Try refreshing — if it keeps happening, contact support.
              </p>
            </div>
            <button className="view-btn" type="button" onClick={loadData} disabled={refreshing}>
              <RefreshCcw size={16} className={refreshing ? 'spinning' : ''} />
              Retry
            </button>
          </div>
        )}
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
            <strong>{loading ? '—' : totalCredits}</strong>
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
              <button className="view-btn" type="button" onClick={loadData} disabled={refreshing}>
                <RefreshCcw size={16} className={refreshing ? 'spinning' : ''} />
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
              <h3>PERIOD SNAPSHOT</h3>
              <Shield size={18} />
            </div>

            {activePeriod ? (
              <div className="student-snapshot-list">
                <div className="student-snapshot-item">
                  <strong>{activePeriod.name}</strong>
                  <span>Term dates</span>
                  <p>{formatDate(activePeriod.startDate)} – {formatDate(activePeriod.endDate)}</p>
                </div>
                <div className="student-snapshot-item">
                  <strong>Grading Window</strong>
                  <span>When grades are being finalized</span>
                  <p>{formatDate(activePeriod.gradingOpen)} – {formatDate(activePeriod.gradingClose)}</p>
                </div>
                <div className="student-snapshot-item">
                  <strong>{enrolledCount}</strong>
                  <span>Courses enrolled</span>
                  <p>{totalCredits} total credits this period</p>
                </div>
              </div>
            ) : (
              <p style={{ color: 'var(--muted)', margin: 0 }}>No active academic period found.</p>
            )}
          </aside>
        </section>
      </section>
      <Modal
        open={noticeOpen}
        title={noticeTitle}
        onClose={() => setNoticeOpen(false)}
        footer={<button type="button" className="primary-mini" onClick={() => setNoticeOpen(false)}>Close</button>}
      >
        <div style={{ whiteSpace: 'pre-line', color: 'var(--text-muted)' }}>{noticeBody}</div>
      </Modal>
    </Shell>
  );
}

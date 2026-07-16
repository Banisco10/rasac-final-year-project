import { useEffect, useState, useMemo } from 'react';
import {
  LayoutDashboard, BookOpen, Users, Shield, FileText,
  Settings, RefreshCcw, Bell, GraduationCap, UserRound,
  ArrowLeft, ShieldCheck, ShieldX, BarChart3,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, Course, Grade, AuthenticatedUser, AuditLog } from '../../types';
import { api } from '../../api';

type CourseMember = {
  id: number;
  fullName: string;
  email: string;
  role: string;
  studentId?: string | null;
  staffId?: string | null;
  department?: string | null;
  isActive: boolean;
};

type CourseDetailData = {
  course: Course;
  lecturer: AuthenticatedUser | null;
  students: CourseMember[];
  grades: Grade[];
};

function usePrefersReducedMotion() {
  const [reduced, setReduced] = useState(
    () => window.matchMedia('(prefers-reduced-motion: reduce)').matches
  );
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const handler = () => setReduced(mq.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);
  return reduced;
}

type BarItem = { label: string; count: number; color: string };

function AnimatedBarBreakdown({ items }: { items: BarItem[] }) {
  const reducedMotion = usePrefersReducedMotion();
  const [mounted, setMounted] = useState(reducedMotion);

  useEffect(() => {
    if (reducedMotion) {
      setMounted(true);
      return;
    }
    setMounted(false);
    const timer = setTimeout(() => setMounted(true), 50);
    return () => clearTimeout(timer);
  }, [items, reducedMotion]);

  const max = Math.max(...items.map((i) => i.count), 1);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {items.map((item) => (
        <div key={item.label}>
          <div style={{
            display: 'flex', justifyContent: 'space-between', fontSize: 11,
            fontFamily: 'var(--font-mono)', letterSpacing: '0.08em', color: 'var(--muted)', marginBottom: 6,
          }}>
            <span>{item.label}</span>
            <strong style={{ color: 'var(--text)' }}>{item.count}</strong>
          </div>
          <div style={{ height: 8, borderRadius: 999, background: 'rgba(255,255,255,0.06)', overflow: 'hidden' }}>
            <div style={{
              height: '100%',
              borderRadius: 999,
              width: mounted ? `${(item.count / max) * 100}%` : '0%',
              background: item.color,
              boxShadow: item.count > 0 ? `0 0 12px ${item.color}66` : 'none',
              transition: reducedMotion ? 'none' : 'width 0.8s cubic-bezier(0.16, 1, 0.3, 1)',
            }} />
          </div>
        </div>
      ))}
    </div>
  );
}

export function CourseDetailScreen({
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const sidebarItems: NavItem[] = [
    { view: 'dashboard',       label: 'Dashboard',      icon: <LayoutDashboard size={20} /> },
    { view: 'course-detail',   label: 'Courses',         icon: <BookOpen size={20} /> },
    { view: 'user-management', label: 'Users',           icon: <Users size={20} /> },
    { view: 'role-management', label: 'Access Control',  icon: <Shield size={20} /> },
    { view: 'audit-logs',      label: 'Audit Logs',      icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const [me, setMe]                   = useState<AuthenticatedUser | null>(null);
  const [courses, setCourses]         = useState<Course[]>([]);
  const [selectedId, setSelectedId]   = useState<number | null>(null);
  const [detail, setDetail]           = useState<CourseDetailData | null>(null);
  const [auditLogs, setAuditLogs]     = useState<AuditLog[]>([]);
  const [loading, setLoading]         = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [error, setError]             = useState<string | null>(null);
  const [page, setPage]               = useState(1);
  const [noticeOpen, setNoticeOpen]   = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody]   = useState('');

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title); setNoticeBody(body); setNoticeOpen(true);
  };

  const displayName = me?.fullName ?? 'Administrator';
  const initials = displayName.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase();

  // Load courses list + me + audit logs on mount
  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    setLoading(true);
    Promise.all([
      api.courses(),
      api.auditLogs(),
    ]).then(([coursesRes, auditRes]) => {
      setCourses(coursesRes.data);
      setAuditLogs(auditRes.data);
    }).catch((err) => {
      setError(err instanceof Error ? err.message : 'Failed to load courses');
    }).finally(() => setLoading(false));
  }, []);

  // Load course detail when a course is selected
  useEffect(() => {
    if (!selectedId) return;
    setDetailLoading(true);
    setDetail(null);
    setPage(1);
    setError(null);
    Promise.all([
      api.course(selectedId),
      api.courseStudents(selectedId),
      api.courseGrades(selectedId),
    ]).then(([courseRes, studentsRes, gradesRes]) => {
      setDetail({
        course: courseRes.course,
        lecturer: courseRes.lecturer,
        students: studentsRes.data,
        grades: gradesRes.data,
      });
    }).catch((err) => {
      setError(err instanceof Error ? err.message : 'Failed to load course details');
    }).finally(() => setDetailLoading(false));
  }, [selectedId]);

  // Course list metrics
  const listMetrics = useMemo(() => {
    const totalEnrollments = courses.reduce((sum) => sum, 0);
    const active = courses.filter((c) => c.isActive).length;
    return { total: courses.length, active, totalEnrollments };
  }, [courses]);

  // Detail metrics
  const students = detail?.students ?? [];
  const grades   = detail?.grades ?? [];

  const averageScore = grades.length
    ? Math.round(grades.reduce((s, g) => s + g.score, 0) / grades.length)
    : null;
  const approvedCount  = grades.filter((g) => g.status === 'APPROVED').length;
  const pendingCount   = grades.filter((g) => g.status === 'SUBMITTED').length;

  // Authorization analytics — filter audit logs for this course's resource
  const courseAuditLogs = useMemo(() => {
    if (!selectedId) return [];
    return auditLogs.filter((log) => log.resourceId === String(selectedId));
  }, [auditLogs, selectedId]);

  
  const authAnalytics = useMemo(() => {
  const granted  = courseAuditLogs.filter((l) => l.outcome === 'GRANTED').length;
  const deniedRole = courseAuditLogs.filter((l) => l.outcome === 'DENIED_ROLE').length;
  const deniedRel  = courseAuditLogs.filter((l) => l.outcome === 'DENIED_RELATIONSHIP').length;
  const deniedCtx  = courseAuditLogs.filter((l) => l.outcome === 'DENIED_CONTEXT').length;
  const total = courseAuditLogs.length;
  return { granted, deniedRole, deniedRel, deniedCtx, total };
}, [courseAuditLogs]);

const totalDenied = authAnalytics.deniedRole + authAnalytics.deniedRel + authAnalytics.deniedCtx;
const denialBarSegments = totalDenied > 0 ? [
  { label: `ROLE (${authAnalytics.deniedRole})`, width: `${Math.round((authAnalytics.deniedRole / totalDenied) * 100)}%`, tone: 'role' },
  { label: `RELATIONSHIP (${authAnalytics.deniedRel})`, width: `${Math.round((authAnalytics.deniedRel / totalDenied) * 100)}%`, tone: 'rel' },
  { label: `CONTEXT (${authAnalytics.deniedCtx})`, width: `${Math.round((authAnalytics.deniedCtx / totalDenied) * 100)}%`, tone: 'cont' },
] : [];

  // Pagination
  const pageSize = 6;
  const totalPages      = Math.max(1, Math.ceil(students.length / pageSize));
  const safePage        = Math.min(page, totalPages);
  const visibleStudents = students.slice((safePage - 1) * pageSize, safePage * pageSize);

  // Grade lookup per student
  const gradeByStudent = useMemo(() => {
    const map = new Map<number, Grade>();
    grades.forEach((g) => map.set(g.studentId, g));
    return map;
  }, [grades]);

  return (
    <Shell
      activeView="course-detail"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search system resources..."
      sidebarItems={sidebarItems}
      footerAction={async () => {
        try {
          const { emergencyLockoutActive } = await api.accessMatrix();
          await api.toggleEmergencyLockout(!emergencyLockoutActive);
          openNotice('Emergency lockout updated', `Emergency lockout ${emergencyLockoutActive ? 'disabled' : 'enabled'}.`);
        } catch (err) {
          openNotice('Unable to update emergency lockout', err instanceof Error ? err.message : 'Unknown error');
        }
      }}
      footerActionClassName="emergency-btn"
      footerActionLabel="Emergency Lockout"
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Security Principal' }}
      topIcons={
        <>
          <button className="icon-chip" type="button" aria-label="Notifications"
            onClick={() => openNotice('Course overview', `${listMetrics.total} courses loaded. ${listMetrics.active} active.`)}
          >
            <Bell size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Settings" onClick={() => onNavigate('system-settings')}>
            <Settings size={20} />
          </button>
          <div className="student-user-chip lecturer-chip">
            <div className="student-user-copy">
              <strong>{displayName.toUpperCase()}</strong>
              <span>ADMIN</span>
            </div>
            <div className="student-user-avatar">{initials}</div>
          </div>
        </>
      }
      topbarClassName="course-main"
    >
      <section className="page-stack course-page">

        {error && (
          <section className="panel-card" role="alert">
            <div className="panel-heading"><h3>Error</h3></div>
            <p style={{ margin: 0, color: 'var(--muted)' }}>{error}</p>
          </section>
        )}

        {/* ── STATE 1: COURSE LIST ── */}
        {!selectedId && (
          <>
            <div className="course-header">
              <div className="course-kicker-row">
                <span className="course-kicker">ACADEMIC OVERVIEW</span>
              </div>
              <h1>Course Registry</h1>
              <p style={{ color: 'var(--muted)', marginTop: 6 }}>
                All courses registered in the current academic period. Click a course to view enrollment and grade detail.
              </p>
            </div>

            {/* List metrics */}
            <div className="course-metrics">
              <div className="course-metric-card">
                <div className="course-metric-label">TOTAL COURSES</div>
                <div className="course-metric-value">{listMetrics.total}</div>
              </div>
              <div className="course-metric-card">
                <div className="course-metric-label">ACTIVE</div>
                <div className="course-metric-value">{listMetrics.active}</div>
              </div>
              <div className="course-metric-card">
                <div className="course-metric-label">INACTIVE</div>
                <div className="course-metric-value">{listMetrics.total - listMetrics.active}</div>
              </div>
              <div className="course-metric-card status-card">
                <div className="course-metric-label">STATUS</div>
                <div className="status-line">
                  <span className="status-dot warning" />
                  {loading ? 'Loading...' : 'Registry synced'}
                </div>
              </div>
            </div>

            {/* Courses table */}
            <section className="panel-card course-table-card">
              <div className="panel-heading course-table-heading">
                <h3>All Courses</h3>
              </div>
              <div className="table-wrap">
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Code</th>
                      <th>Title</th>
                      <th>Credits</th>
                      <th>Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading && (
                      <tr>
                        <td colSpan={5} style={{ textAlign: 'center', color: 'var(--muted)', padding: 24 }}>
                          Loading courses...
                        </td>
                      </tr>
                    )}
                    {!loading && courses.length === 0 && (
                      <tr>
                        <td colSpan={5} style={{ textAlign: 'center', color: 'var(--muted)', padding: 24 }}>
                          No courses found.
                        </td>
                      </tr>
                    )}
                    {courses.map((course) => (
                      <tr key={course.id}>
                        <td><strong>{course.code}</strong></td>
                        <td>{course.title}</td>
                        <td>{course.credits}</td>
                        <td>
                          <span className={`pill ${course.isActive ? 'ok' : 'deny'}`}>
                            {course.isActive ? 'ACTIVE' : 'INACTIVE'}
                          </span>
                        </td>
                        <td>
                          <button
                            className="view-btn"
                            type="button"
                            onClick={() => setSelectedId(course.id)}
                          >
                            VIEW DETAIL
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div style={{ padding: '14px 18px', color: 'var(--muted)', fontSize: 13 }}>
                {courses.length} course{courses.length !== 1 ? 's' : ''} in registry
              </div>
            </section>
          </>
        )}

        {/* ── STATE 2: COURSE DETAIL ── */}
        {selectedId && (
          <>
            {/* Back button */}
            <button
              type="button"
              className="outlined-btn"
              style={{ alignSelf: 'flex-start', display: 'flex', alignItems: 'center', gap: 8 }}
              onClick={() => { setSelectedId(null); setDetail(null); setError(null); }}
            >
              <ArrowLeft size={16} /> Back to Courses
            </button>

            {detailLoading ? (
              <div style={{ color: 'var(--muted)', padding: 24 }}>Loading course details...</div>
            ) : detail ? (
              <>
                {/* Course header */}
                <div className="course-header">
                  <div className="course-kicker-row">
                    <span className="course-code">{detail.course.code}</span>
                    <span className="course-kicker-line" />
                    <span className="course-kicker">COURSE ENROLLMENT DETAIL</span>
                  </div>
                  <h1>{detail.course.title}</h1>
                  <div className="course-meta-row">
                    <span>
                      <GraduationCap size={18} /> {detail.course.credits} credits
                    </span>
                    <span>
                      <UserRound size={18} /> Lecturer: <strong>{detail.lecturer?.fullName ?? '—'}</strong>
                    </span>
                  </div>
                </div>

                {/* Detail metrics — all real data */}
                <div className="course-metrics">
                  <div className="course-metric-card">
                    <div className="course-metric-label">ENROLLED</div>
                    <div className="course-metric-value">{students.length}</div>
                    <div className="progress-track">
                      <div className="progress-fill" style={{ width: `${Math.min(100, students.length * 14)}%` }} />
                    </div>
                  </div>
                  <div className="course-metric-card">
                    <div className="course-metric-label">GRADE AVG</div>
                    <div className="course-metric-value">{averageScore !== null ? `${averageScore}%` : '—'}</div>
                    <div className="course-metric-sub">{grades.length} submission{grades.length !== 1 ? 's' : ''}</div>
                  </div>
                  <div className="course-metric-card">
                    <div className="course-metric-label">APPROVED</div>
                    <div className="course-metric-value">{approvedCount}</div>
                    <div className="course-metric-sub">{pendingCount} pending approval</div>
                  </div>
                  <div className="course-metric-card status-card">
                    <div className="course-metric-label">STATUS</div>
                    <div className="status-line">
                      <span className={`status-dot ${detail.course.isActive ? 'success' : 'warning'}`} />
                      {detail.course.isActive ? 'Active' : 'Inactive'}
                    </div>
                    <div className="course-metric-sub upper">{detail.course.code}</div>
                  </div>
                </div>

                {/* Students table */}
                <section className="panel-card course-table-card">
                  <div className="panel-heading course-table-heading">
                    <h3>Enrolled Students</h3>
                    <span style={{ fontSize: 13, color: 'var(--muted)' }}>
                      {students.length} enrolled
                    </span>
                  </div>
                  <div className="table-wrap">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Student</th>
                          <th>Email</th>
                          <th>Grade</th>
                          <th>Grade Status</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {visibleStudents.length === 0 && (
                          <tr>
                            <td colSpan={5} style={{ textAlign: 'center', color: 'var(--muted)', padding: 24 }}>
                              No students enrolled.
                            </td>
                          </tr>
                        )}
                        {visibleStudents.map((student) => {
                          const grade = gradeByStudent.get(student.id);
                          return (
                            <tr key={student.id}>
                              <td>
                                <div className="student-name">{student.fullName}</div>
                                <div className="student-id">{student.studentId ?? `ID ${student.id}`}</div>
                              </td>
                              <td style={{ fontFamily: 'var(--font-mono)', fontSize: 12 }}>{student.email}</td>
                              <td>
                                {grade ? (
                                  <strong style={{ fontSize: 15, color: 'var(--accent)' }}>{grade.grade}</strong>
                                ) : (
                                  <span style={{ color: 'var(--muted)' }}>—</span>
                                )}
                              </td>
                              <td>
                                {grade ? (
                                  <span className={`pill ${grade.status === 'APPROVED' ? 'ok' : grade.status === 'REJECTED' ? 'deny' : 'warn'}`}>
                                    {grade.status}
                                  </span>
                                ) : (
                                  <span className="pill">NOT GRADED</span>
                                )}
                              </td>
                              <td>
                                <button
                                  className="view-btn"
                                  type="button"
                                  onClick={() => openNotice(
                                    student.fullName,
                                    `Email: ${student.email}\nStudent ID: ${student.studentId ?? '—'}\nStatus: ${student.isActive ? 'Active' : 'Inactive'}${grade ? `\n\nGrade: ${grade.grade} (${grade.score}%)\nStatus: ${grade.status}` : '\n\nNo grade recorded yet.'}`
                                  )}
                                >
                                  VIEW
                                </button>
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                  <div className="table-footer">
                    <span>
                      Showing {(safePage - 1) * pageSize + (visibleStudents.length > 0 ? 1 : 0)}–{(safePage - 1) * pageSize + visibleStudents.length} of {students.length}
                    </span>
                    <div className="pagination">
                      <button type="button" onClick={() => setPage((p) => Math.max(1, p - 1))}>&lt;</button>
                      <button type="button" className="active">{safePage}</button>
                      <button type="button" onClick={() => setPage((p) => Math.min(totalPages, p + 1))}>&gt;</button>
                    </div>
                  </div>
                </section>

                {/* Authorization analytics */}
                <div className="bottom-two">
                  <section className="panel-card side-summary-card">
                    <div className="panel-heading">
                      <h3>Authorization Analytics</h3>
                      <BarChart3 size={18} />
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, padding: '16px 18px 4px' }}>
                      <div className="metric-tile">
                        <div className="metric-title">TOTAL</div>
                        <div className="metric-number small">{authAnalytics.total}</div>
                      </div>
                      <div className="metric-tile green">
                        <div className="metric-title">GRANTED</div>
                        <div className="metric-number small">{authAnalytics.granted}</div>
                      </div>
                      <div className="metric-tile pink">
                        <div className="metric-title">GRANT RATE</div>
                        <div className="metric-number small">
                          {authAnalytics.total > 0 ? Math.round((authAnalytics.granted / authAnalytics.total) * 100) : 0}%
                        </div>
                      </div>
                    </div>

                    <div style={{ padding: '18px' }}>
                      <div style={{ fontSize: 11, color: 'var(--muted)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                        Denials by layer
                      </div>
                      {totalDenied > 0 ? (
                        <AnimatedBarBreakdown
                          items={[
                            { label: 'ROLE', count: authAnalytics.deniedRole, color: '#6b7db3' },
                            { label: 'RELATIONSHIP', count: authAnalytics.deniedRel, color: '#45f0cf' },
                            { label: 'CONTEXT', count: authAnalytics.deniedCtx, color: '#8a8fa8' },
                          ]}
                        />
                      ) : (
                        <div style={{ fontSize: 12, color: 'var(--muted)' }}>No denials recorded for this course.</div>
                      )}
                    </div>
                  </section>

                  <section className="panel-card side-summary-card">
                    <div className="panel-heading">
                      <h3>Authorization Analytics</h3>
                      <BarChart3 size={18} />
                    </div>

                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, padding: '16px 18px 4px' }}>
                      <div className="metric-tile">
                        <div className="metric-title">TOTAL</div>
                        <div className="metric-number small">{authAnalytics.total}</div>
                      </div>
                      <div className="metric-tile green">
                        <div className="metric-title">GRANTED</div>
                        <div className="metric-number small">{authAnalytics.granted}</div>
                      </div>
                      <div className="metric-tile pink">
                        <div className="metric-title">GRANT RATE</div>
                        <div className="metric-number small">
                          {authAnalytics.total > 0 ? Math.round((authAnalytics.granted / authAnalytics.total) * 100) : 0}%
                        </div>
                      </div>
                    </div>

                    <div style={{ padding: '18px' }}>
                      <div style={{ fontSize: 11, color: 'var(--muted)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                        Denials by layer
                      </div>
                      {totalDenied > 0 ? (
                        <AnimatedBarBreakdown
                          items={[
                            { label: 'ROLE', count: authAnalytics.deniedRole, color: '#6b7db3' },
                            { label: 'RELATIONSHIP', count: authAnalytics.deniedRel, color: '#45f0cf' },
                            { label: 'CONTEXT', count: authAnalytics.deniedCtx, color: '#8a8fa8' },
                          ]}
                        />
                      ) : (
                        <div style={{ fontSize: 12, color: 'var(--muted)' }}>No denials recorded for this course.</div>
                      )}
                    </div>
                  </section>
                </div>
              </>
            ) : null}
          </>
        )}
      </section>

      <Modal
        open={noticeOpen}
        title={noticeTitle}
        description=""
        onClose={() => setNoticeOpen(false)}
        footer={<button type="button" className="primary-mini" onClick={() => setNoticeOpen(false)}>Close</button>}
      >
        <div style={{ whiteSpace: 'pre-line', color: 'var(--text-muted)' }}>{noticeBody}</div>
      </Modal>
    </Shell>
  );
}
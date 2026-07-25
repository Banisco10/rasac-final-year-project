import { useEffect, useState } from 'react';
import {
  LayoutDashboard,
  FileText,
  BookOpen,
  NotebookPen,
  UserRound,
  Bell,
  History,
  Shield,
  RefreshCcw,
  AlertTriangle
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, Course, AuditLog, AuthenticatedUser, AcademicPeriod } from '../../types';
import { api } from '../../api';
import type { PreviousLoginInfo } from '../../../../shared/types.js';


type CourseProgress = {
  studentCount: number;
  gradedCount: number;
  draftCount: number;
  submittedCount: number;
  rejectedCount: number;
};


export function LecturerDashboardScreen({
  previousLogin,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  previousLogin?: PreviousLoginInfo | null;
  onNavigate: (view: View, params?: Record<string, string>) => void;
  onLogout: () => void;
}) {
  const sidebarItems: NavItem[] = [
    { view: 'lecturer-dashboard', label: 'Dashboard',       icon: <LayoutDashboard size={20} /> },
    { view: 'lecturer-grading',   label: 'Grading Portal',  icon: <NotebookPen size={20} /> },
    { view: 'lecturer-profile',   label: 'My Profile',      icon: <UserRound size={20} /> },
    { view: 'lecturer-activity',  label: 'My Activity',     icon: <FileText size={20} /> },
  ];

  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [trail, setTrail] = useState<AuditLog[]>([]);
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);
  const [courseProgress, setCourseProgress] = useState<Record<number, CourseProgress>>({});
  const [welcomeBannerOpen, setWelcomeBannerOpen] = useState(Boolean(previousLogin?.lastLogin));
  const [searchQuery, setSearchQuery] = useState('');
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [visCourseId, setVisCourseId] = useState<number | null>(null);

useEffect(() => {
  if (courses.length === 0) {
    setVisCourseId(null);
    return;
  }
  if (!visCourseId || !courses.some((c) => c.id === visCourseId)) {
    setVisCourseId(courses[0].id);
  }
}, [courses]);


  const loadData = async () => {
    setLoading(true);
    try {
      const [meRes, coursesRes, progressRows, trailRes, periodRes] = await Promise.all([
        api.me(),
        api.courses(),
        api.myGradingProgress()
      .then((rows) => {
        const map: Record<number, CourseProgress> = {};
        rows.forEach((row) => {
          map[row.courseId] = {
            studentCount: row.studentCount,
            gradedCount: row.gradedCount,
            draftCount: row.draftCount,
            submittedCount: row.submittedCount,
            rejectedCount: row.rejectedCount,
          };
        });
        setCourseProgress(map);
      })
      .catch(console.error),
        api.auditMy(),
        api.activePeriod(),
      ]);

      setMe(meRes);
      setCourses(coursesRes.data);

      setTrail(trailRes);
      setActivePeriod(periodRes);
      setLoadError(null);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to reach the RASAC server.');
    } finally {
      setLoading(false);
    }
  };


  useEffect(() => {
    loadData();
  }, []);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };


  const gradingHoursLeft = activePeriod?.gradingClose
  ? Math.max(0, Math.round((new Date(activePeriod.gradingClose).getTime() - Date.now()) / (1000 * 60 * 60)))
  : null;

  const showGradingWarning = gradingHoursLeft !== null && gradingHoursLeft <= 168; // 7 days

  const filteredCourses = courses.filter((course) => {
    const text = searchQuery.toLowerCase();
    return (
      String(course.code || '').toLowerCase().includes(text) ||
      String(course.title || '').toLowerCase().includes(text)
    );
  });

  const filteredTrail = trail.filter((item) => {
    const text = searchQuery.toLowerCase();
    return (
      String(item.action || '').toLowerCase().includes(text) ||
      String(item.resource || '').toLowerCase().includes(text)
    );
  });

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase();

  return (
    <Shell
      activeView="lecturer-dashboard"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="LECTURER ROLE"
      searchPlaceholder="Search courses..."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
      sidebarItems={sidebarItems}
      footerAction={() => onNavigate('lecturer-profile')}
      footerActionClassName="deploy-btn"
      footerActionLabel="View Profile"
      footerActionIcon={<UserRound size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Lecturer' }}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications" onClick={() => openNotice('Notifications', `You have ${courses.length} active courses.`)}><Bell size={20} /></button>
          <button className="icon-chip" aria-label="Refresh" disabled={loading} onClick={loadData}>
            <RefreshCcw size={20} className={loading ? 'spin-icon' : ''} />
          </button>
          <button className="icon-chip" aria-label="History" onClick={() => openNotice('History Logs', `Total operations recorded: ${trail.length}`)}><History size={20} /></button>
          <div className="student-user-chip lecturer-chip">
            <div className="student-user-copy">
              <strong>{displayName.toUpperCase()}</strong>
              <span>LECTURER</span>
            </div>
            <div className="student-user-avatar">{initials}</div>
          </div>
        </>
      }
      topbarClassName="portal-main"
    >
      <section className="page-stack portal-page lecturer-page">
        <style>{`
          @keyframes rasac-spin { to { transform: rotate(360deg); } }
          .spin-icon { animation: rasac-spin 0.7s linear infinite; transform-origin: center; }
          @keyframes rasac-pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.45; } }
        `}</style>
        {loadError && (
          <div className="portal-banner warning">
            <div>
              <strong>Couldn't load dashboard data</strong>
              <p>{loadError}</p>
            </div>
            <button className="primary-mini" type="button" onClick={loadData}>
              Retry
            </button>
          </div>
        )}
        {welcomeBannerOpen && previousLogin && (
          <div className="portal-banner">
            <div>
              <strong>Welcome back, {displayName}</strong>
              <p>
                Last login: {previousLogin.lastLogin ? new Date(previousLogin.lastLogin).toLocaleString() : 'first recorded login'}
              </p>
              {previousLogin.ipAddress && (
                <p>Station IP: {previousLogin.ipAddress}</p>
              )}
            </div>
            <button className="outlined-btn" type="button" onClick={() => setWelcomeBannerOpen(false)}>
              Dismiss
            </button>
          </div>
        )}
        {showGradingWarning && activePeriod && (
          <div className="portal-banner warning">
            <div>
              <strong>Grading Window Closing</strong>
              <p>
                The {activePeriod.name} grading period concludes in{' '}
                {gradingHoursLeft! >= 24 ? `${Math.round(gradingHoursLeft! / 24)} day(s)` : `${gradingHoursLeft} hour(s)`}.
                Please finalize all grade submissions.
              </p>
            </div>
            <button className="primary-mini" type="button" onClick={() => onNavigate('lecturer-grading')}>
              Go to Grading
            </button>
          </div>
        )}

        <div className="portal-hero lecturer-hero">
          <div className="portal-hero-copy">
            <div className="hero-kicker">LECTURER DASHBOARD</div>
            <h1>{displayName}</h1>
            <p>{me?.department ?? 'Computer Science'} - Senior Lecturer</p>
          </div>
          <div className="portal-hero-actions">
            <button className="primary-mini" type="button" onClick={() => onNavigate('lecturer-grading')}>
              Go to Grading
            </button>
            <button className="outlined-btn" type="button" onClick={() => onNavigate('lecturer-profile')}>
              View Profile
            </button>
          </div>
        </div>

        <div className="portal-grid lecturer-grid">
          <section className="panel-card lecturer-course-card">
            <div className="panel-heading">
              <h3>My Active Courses</h3>
              <span className="status-pill granted">{filteredCourses.length} TOTAL</span>
            </div>
            <div className="lecturer-course-list">
              {filteredCourses.length === 0 && (
                <p style={{ color: 'var(--muted)', padding: '12px 0' }}>No courses assigned.</p>
              )}
              {filteredCourses.map((course) => (
                <article className="lecturer-course-item" key={course.code}>
                  <div className="lecturer-course-code">{course.code}</div>
                  <div className="lecturer-course-body">
                    <strong>{course.title}</strong>
                    <span>{course.credits} credits</span>
                  </div>
                  <div className="lecturer-course-progress">
                    {(() => {
                      const progress = courseProgress[course.id];
                      const pct = progress && progress.studentCount > 0
                        ? Math.round((progress.gradedCount / progress.studentCount) * 100)
                        : 0;
                      return (
                        <>
                          <div className="progress-track small">
                            <div className="progress-fill" style={{ width: `${pct}%` }} />
                          </div>
                          <span>{progress ? `${pct}%` : '-'}</span>
                        </>
                      );
                    })()}
                  </div>
                  <button
                    className="queue-action approve"
                    type="button"
                    onClick={() => onNavigate('lecturer-grading', { courseId: String(course.id) })}
                  >
                    SUBMIT GRADES
                  </button>
                </article>
              ))}
            </div>
          </section>

          <section className="panel-card lecturer-trail-card">
            <div className="panel-heading">
              <h3>Personal Audit Trail</h3>
              <span className="live-chip"><span />LIVE</span>
            </div>
            <div className="trail-list">
              {filteredTrail.length === 0 && (
                <p style={{ color: 'var(--muted)', padding: '12px 0' }}>No activity yet.</p>
              )}
              {filteredTrail.slice(0, 10).map((item) => (
                <div className="trail-item" key={item.id}>
                  <div className="trail-title">{item.action}</div>
                  <div className="trail-body">{item.resource}</div>
                  <div className="trail-time">{new Date(item.timestamp).toLocaleTimeString()}</div>
                </div>
              ))}
            </div>
            <button className="view-all" type="button" onClick={() => openNotice('Audit Trail', `Total logs: ${trail.length}`)}>VIEW FULL LOG</button>
          </section>

          <section className="panel-card lecturer-visual-card">
            <div className="panel-heading">
              <h3>Grade Pipeline</h3>
              <span className="lecturer-node-label">
                {Object.values(courseProgress).reduce((sum, p) => sum + p.studentCount, 0) > 0
                  ? `${Object.values(courseProgress).reduce((sum, p) => sum + p.draftCount + p.submittedCount + p.gradedCount + p.rejectedCount, 0)} total`
                  : '0 total'}
              </span>
            </div>
            {(() => {
              const totals = Object.values(courseProgress).reduce(
                (acc, p) => ({
                  draft: acc.draft + p.draftCount,
                  submitted: acc.submitted + p.submittedCount,
                  approved: acc.approved + p.gradedCount,
                  rejected: acc.rejected + p.rejectedCount,
                }),
                { draft: 0, submitted: 0, approved: 0, rejected: 0 }
              );
              const total = totals.draft + totals.submitted + totals.approved + totals.rejected;

              if (total === 0) {
                return <p style={{ color: 'var(--muted)', padding: '20px 0', textAlign: 'center' }}>No grade records yet.</p>;
              }

              const segments = [
                { label: 'Draft', count: totals.draft, color: 'var(--muted)' },
                { label: 'Submitted', count: totals.submitted, color: 'var(--warn)' },
                { label: 'Approved', count: totals.approved, color: 'var(--success)' },
                { label: 'Rejected', count: totals.rejected, color: 'var(--danger)' },
              ];

              return (
                <div style={{ padding: '4px 2px' }}>
                  <div style={{ display: 'flex', height: 14, borderRadius: 999, overflow: 'hidden' }}>
                    {segments.map((seg) => seg.count > 0 && (
                      <div
                        key={seg.label}
                        style={{
                          width: `${(seg.count / total) * 100}%`,
                          background: seg.color,
                          opacity: seg.label === 'Rejected' && seg.count > 0 ? undefined : 1,
                          animation: seg.label === 'Rejected' && seg.count > 0 ? 'rasac-pulse 1.8s ease-in-out infinite' : undefined,
                        }}
                      />
                    ))}
                  </div>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px 18px', marginTop: 12, fontSize: 12 }}>
                    {segments.map((seg) => (
                      <span key={seg.label} style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--muted)' }}>
                        <span style={{ width: 8, height: 8, borderRadius: '50%', background: seg.color, display: 'inline-block' }} />
                        {seg.label}: <strong style={{ color: 'var(--text)' }}>{seg.count}</strong>
                        {seg.label === 'Rejected' && seg.count > 0 && <AlertTriangle size={13} color="var(--danger)" />}
                      </span>
                    ))}
                  </div>
                </div>
              );
            })()}
          </section>

          <section className="panel-card lecturer-context-card">
            <div className="panel-heading">
              <h3>Security Context</h3>
              <Shield size={18} />
            </div>
            <div className="context-grid">
              <div className="context-box">
                <span>ROLE</span>
                <strong>{me?.role ?? 'LECTURER'}</strong>
              </div>
              <div className="context-box">
                <span>ACTIVE COURSES</span>
                <strong>{courses.length}</strong>
              </div>
            </div>
            <div className="context-binding">
              <span>RELATIONSHIP BINDING</span>
              <strong>STAFF_ACADEMIC - DEPT_{me?.department?.toUpperCase().replace(' ', '_') ?? 'CS'}</strong>
            </div>
          </section>
        </div>
      </section>

      <Modal
        open={noticeOpen}
        title={noticeTitle}
        description={noticeBody}
        onClose={() => setNoticeOpen(false)}
        footer={<button type="button" className="primary-mini" onClick={() => setNoticeOpen(false)}>Close</button>}
      >
        <div style={{ whiteSpace: 'pre-line', color: 'var(--text-muted)' }}>{noticeBody}</div>
      </Modal>
    </Shell>
  );
}

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
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, Course, AuditLog, AuthenticatedUser } from '../../types';
import { api } from '../../api';
import type { PreviousLoginInfo } from '../../../../shared/types.js';

export function LecturerDashboardScreen({
  previousLogin,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  previousLogin?: PreviousLoginInfo | null;
  onNavigate: (view: View) => void;
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
  const [welcomeBannerOpen, setWelcomeBannerOpen] = useState(Boolean(previousLogin?.lastLogin));
  const [searchQuery, setSearchQuery] = useState('');
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');

  const loadData = () => {
    api.me().then(setMe).catch(console.error);
    api.courses().then((response) => setCourses(response.data)).catch(console.error);
    api.auditMy().then(setTrail).catch(console.error);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

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
          <button className="icon-chip" aria-label="Notifications" onClick={() => openNotice('Notifications', `Clearance: LEVEL_3. You have ${courses.length} active courses.`)}><Bell size={20} /></button>
          <button className="icon-chip" aria-label="Refresh" onClick={loadData}><RefreshCcw size={20} /></button>
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
        <div className="portal-banner warning">
          <div>
            <strong>Grading Window Closing</strong>
            <p>The Q3 final assessment period concludes in 48 hours. Please finalize all grade submissions.</p>
          </div>
          <button className="primary-mini" type="button" onClick={() => onNavigate('lecturer-grading')}>
            Go to Grading
          </button>
        </div>

        <div className="portal-hero lecturer-hero">
          <div className="portal-hero-copy">
            <div className="hero-kicker">LECTURER DASHBOARD</div>
            <h1>{displayName}</h1>
            <p>{me?.department ?? 'Computer Science'} — Senior Lecturer</p>
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
                    <div className="progress-track small">
                      <div className="progress-fill" style={{ width: '86%' }} />
                    </div>
                    <span>86%</span>
                  </div>
                  <button
                    className="queue-action approve"
                    type="button"
                    onClick={() => onNavigate('lecturer-grading')}
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
              <h3>Relationship Visualization</h3>
              <span className="lecturer-node-label">NODE: LECTURER → COURSE → STUDENT</span>
            </div>
            <div className="relationship-graph">
              <div className="graph-layer">
                <span className="graph-dot" />
                <span className="graph-dot" />
                <span className="graph-dot" />
              </div>
              <div className="graph-core">
                <span className="graph-node course">{courses[0]?.code ?? 'COURSE'}</span>
                <span className="graph-node lecturer">{initials}</span>
                <span className="graph-node student">Students</span>
              </div>
            </div>
          </section>

          <section className="panel-card lecturer-context-card">
            <div className="panel-heading">
              <h3>Security Context</h3>
              <Shield size={18} />
            </div>
            <div className="context-grid">
              <div className="context-box">
                <span>CLEARANCE</span>
                <strong>LEVEL_3</strong>
              </div>
              <div className="context-box">
                <span>MFA STATUS</span>
                <strong>VERIFIED</strong>
              </div>
            </div>
            <div className="context-binding">
              <span>RELATIONSHIP BINDING</span>
              <strong>STAFF_ACADEMIC → DEPT_{me?.department?.toUpperCase().replace(' ', '_') ?? 'CS'}</strong>
            </div>
            <button className="primary-mini context-plus" type="button">+</button>
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

import { useEffect, useState } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  NotebookPen,
  Bell,
  History,
  FileText,
  BadgeInfo,
  UserRoundCheck,
  Mail,
  MapPin,
  Clock3,
  UserRound,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, NavItem, AuthenticatedUser, Course, AuditLog } from '../../types';
import { api } from '../../api';

export function LecturerProfileScreen({
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
    const sidebarItems: NavItem[] = [
      { view: 'lecturer-dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
      { view: 'lecturer-grading', label: 'Grading Portal', icon: <NotebookPen size={20} /> },
      { view: 'lecturer-profile', label: 'My Profile', icon: <UserRound size={20} /> },
      { view: 'lecturer-activity', label: 'My Activity', icon: <FileText size={20} /> },
    ];

  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [activity, setActivity] = useState<AuditLog[]>([]);

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.courses().then((response) => setCourses(response.data)).catch(console.error);
    api.auditMy().then(setActivity).catch(console.error);
  }, []);

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase();

  return (
    <Shell
      activeView="lecturer-profile"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="LECTURER ROLE"
      searchPlaceholder="Search courses..."
      sidebarItems={sidebarItems}
      footerAction={() => onNavigate('lecturer-dashboard')}
      footerActionClassName="deploy-btn"
      footerActionLabel="Back to Dashboard"
      footerActionIcon={<UserRound size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Lecturer' }}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications"><Bell size={20} /></button>
          <button className="icon-chip" aria-label="History"><History size={20} /></button>
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
      <section className="page-stack profile-page">
        <div className="profile-hero">
          <div className="profile-hero-avatar">{initials}</div>
          <div className="profile-hero-copy">
            <div className="hero-kicker">LECTURER PROFILE</div>
            <h1>{displayName}</h1>
            <span className="profile-badge">SENIOR LECTURER</span>
            <p>
              {me?.department ?? 'Computer Science'} faculty member with active course assignments
              and live audit visibility.
            </p>
            <div className="portal-hero-actions">
              <button className="primary-mini" type="button">
                Email Lecturer
              </button>
              <button
                className="outlined-btn"
                type="button"
                onClick={() => onNavigate('lecturer-dashboard')}
              >
                Back to Dashboard
              </button>
            </div>
          </div>
        </div>

        <div className="profile-grid">
          <section className="panel-card biography-card">
            <div className="panel-heading">
              <h3>Biography</h3>
              <BadgeInfo size={18} />
            </div>
            <p>
              {displayName} is managed directly by the institutional identity store and is synced
              from the Postgres backend.
            </p>
          </section>

          <section className="panel-card identity-card">
            <div className="panel-heading">
              <h3>Academic Identity</h3>
              <UserRoundCheck size={18} />
            </div>
            <div className="identity-row">
              <span>Department</span>
              <strong>{me?.department ?? 'Computer Science'}</strong>
            </div>
            <div className="identity-row">
              <span>Employee ID</span>
              <strong>{me?.staffId ?? '—'}</strong>
            </div>
            <div className="identity-row">
              <span>Email</span>
              <strong>{me?.email ?? '—'}</strong>
            </div>
            <div className="identity-row">
              <span>Clearance Level</span>
              <strong>3 of 5</strong>
            </div>
          </section>

          <section className="panel-card activity-card">
            <div className="panel-heading">
              <h3>Recent System Activity</h3>
              <History size={18} />
            </div>
            <div className="activity-list">
              {activity.length === 0 && (
                <p style={{ color: 'var(--muted)', padding: '12px 0' }}>No activity yet.</p>
              )}
              {activity.slice(0, 8).map((item) => (
                <div className="activity-item" key={item.id}>
                  <div className="activity-icon"><FileText size={16} /></div>
                  <div className="activity-copy">
                    <strong>{item.action}</strong>
                    <span>{item.resource}</span>
                  </div>
                  <time>{new Date(item.timestamp).toLocaleTimeString()}</time>
                </div>
              ))}
            </div>
          </section>

          <section className="panel-card contact-card">
            <div className="panel-heading">
              <h3>Contact Information</h3>
              <Mail size={18} />
            </div>
            <div className="contact-row">
              <Mail size={16} />
              <div>
                <span>Email</span>
                <strong>{me?.email ?? '—'}</strong>
              </div>
            </div>
            <div className="contact-row">
              <MapPin size={16} />
              <div>
                <span>Office</span>
                <strong>Engineering Block, Room 4B</strong>
              </div>
            </div>
            <div className="contact-row">
              <Clock3 size={16} />
              <div>
                <span>Consultation Hours</span>
                <strong>Mon/Wed 14:00 – 16:00</strong>
              </div>
            </div>
          </section>

          <section className="panel-card courses-card">
            <div className="panel-heading">
              <h3>Active Courses</h3>
              <BookOpen size={18} />
            </div>
            <div className="active-course-list">
              {courses.length === 0 && (
                <p style={{ color: 'var(--muted)', padding: '12px 0' }}>No courses assigned.</p>
              )}
              {courses.map((course) => (
                <div className="active-course-item" key={course.code}>
                  <span>{course.title}</span>
                  <strong>{course.code}</strong>
                </div>
              ))}
            </div>
          </section>
        </div>
      </section>
    </Shell>
  );
}

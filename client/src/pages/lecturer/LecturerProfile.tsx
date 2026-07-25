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
  Pencil,
  Check,
  X,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
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
  const [editingContact, setEditingContact] = useState(false);
  const [officeLocation, setOfficeLocation] = useState('');
  const [officeInput, setOfficeInput] = useState('');
  const [hoursInput, setHoursInput] = useState('');
  const [consultationHours, setConsultationHours] = useState('');
  const [savingContact, setSavingContact] = useState(false);
  const [contactError, setContactError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');

  const loadProfile = async () => {
    setLoading(true);
    try {
      const [meRes, coursesRes, activityRes] = await Promise.all([
        api.me(),
        api.courses(),
        api.auditMy(),
      ]);
      setMe(meRes);
      setCourses(coursesRes.data);
      setActivity(activityRes);
      setLoadError(null);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to reach the RASAC server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfile();
  }, []);

  useEffect(() => {
    setOfficeInput(me?.officeLocation ?? '');
    setHoursInput(me?.consultationHours ?? '');
  }, []);

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase();

  const openNotice = (title: string, body: string) => {
  setNoticeTitle(title);
  setNoticeBody(body);
  setNoticeOpen(true);
};

  const handleSaveContact = async () => {
    if (officeInput.length > 160 || hoursInput.length > 160) {
      setContactError('Each field must be 160 characters or fewer.');
      return;
    }
    setSavingContact(true);
    setContactError(null);
    try {
      const { user } = await api.updateMyContactInfo({
        officeLocation: officeInput.trim(),
        consultationHours: hoursInput.trim(),
      });
      setMe(user);
      setEditingContact(false);
    } catch (error) {
      setContactError(error instanceof Error ? error.message : 'Unable to save contact info.');
    } finally {
      setSavingContact(false);
    }
  };

  const startContactEdit = () => {
    setOfficeLocation(me?.officeLocation ?? '');
    setConsultationHours(me?.consultationHours ?? '');
    setContactError(null);
    setEditingContact(true);
  };

  const cancelContactEdit = () => {
    setOfficeLocation(me?.officeLocation ?? '');
    setConsultationHours(me?.consultationHours ?? '');
    setContactError(null);
    setEditingContact(false);
  };

  const saveContactInfo = async () => {
    if (officeLocation.trim().length > 160 || consultationHours.trim().length > 160) {
      setContactError('Office and consultation hours must be 160 characters or fewer.');
      return;
    }

    setSavingContact(true);
    setContactError(null);
    try {
      const response = await api.updateMyContactInfo({
        officeLocation: officeLocation.trim(),
        consultationHours: consultationHours.trim(),
      });
      setMe(response.user);
      setEditingContact(false);
    } catch (error) {
      setContactError(error instanceof Error ? error.message : 'Unable to save contact information.');
    } finally {
      setSavingContact(false);
    }
  };

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
          <button
            className="icon-chip"
            aria-label="Notifications"
            onClick={() => openNotice(
              'Profile summary',
              `${courses.length} active course${courses.length === 1 ? '' : 's'}. ${activity.length} recent activity entries. Contact info ${me?.officeLocation || me?.consultationHours ? 'is set' : 'has not been set yet'}.`
            )}
          >
            <Bell size={20} />
          </button>
          <button className="icon-chip" aria-label="Refresh" disabled={loading} onClick={loadProfile}>
            <History size={20} className={loading ? 'spin-icon' : ''} />
          </button>
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
        <style>{`
          @keyframes rasac-spin { to { transform: rotate(360deg); } }
          .spin-icon { animation: rasac-spin 0.7s linear infinite; transform-origin: center; }
        `}</style>
        {loadError && (
          <div className="portal-banner warning">
            <div>
              <strong>Couldn't load profile data</strong>
              <p>{loadError}</p>
            </div>
            <button className="primary-mini" type="button" onClick={loadProfile}>
              Retry
            </button>
          </div>
        )}
        <div className="profile-hero">
          <div className="profile-hero-avatar">{initials}</div>
          <div className="profile-hero-copy">
            <div className="hero-kicker">LECTURER PROFILE</div>
            <h1>{displayName}</h1>
            <span className="profile-badge">{me?.role ?? 'LECTURER'}</span>
            <p>
              {me?.department ?? 'Computer Science'} faculty member with active course assignments
              and live audit visibility.
            </p>
            <div className="portal-hero-actions">
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
              {displayName} is a {me?.role?.toLowerCase() ?? 'lecturer'} in the {me?.department ?? 'Computer Science'} department,
              currently teaching {courses.length} course{courses.length === 1 ? '' : 's'} within the RASAC framework.
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
              <strong>{me?.staffId ?? '-'}</strong>
            </div>
            <div className="identity-row">
              <span>Email</span>
              <strong>{me?.email ?? '-'}</strong>
            </div>
            <div className="identity-row">
              <span>Role</span>
              <strong>{me?.role ?? 'LECTURER'}</strong>
            </div>
          </section>


          <section className="panel-card activity-card">
            <div className="panel-heading">
              <h3>Recent System Activity</h3>
              <button type="button" className="view-btn" onClick={() => onNavigate('lecturer-activity')}>
                View Full Log
              </button>
            </div>
            <div className="activity-list">
              {activity.length === 0 && (
                <p style={{ color: 'var(--muted)', padding: '12px 0' }}>No activity yet.</p>
              )}
              {[...activity]
                .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
                .slice(0, 8)
                .map((item) => (
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
              {editingContact ? (
                <div style={{ display: 'flex', gap: 6 }}>
                  <button
                    type="button"
                    className="icon-chip"
                    aria-label="Cancel"
                    disabled={savingContact}
                    onClick={() => {
                      setEditingContact(false);
                      setContactError(null);
                      setOfficeInput(me?.officeLocation ?? '');
                      setHoursInput(me?.consultationHours ?? '');
                    }}
                  >
                    <X size={16} />
                  </button>
                  <button
                    type="button"
                    className="icon-chip"
                    aria-label="Save"
                    disabled={savingContact}
                    onClick={handleSaveContact}
                  >
                    <Check size={16} />
                  </button>
                </div>
              ) : (
                <button type="button" className="icon-chip" aria-label="Edit contact info" onClick={() => setEditingContact(true)}>
                  <Pencil size={16} />
                </button>
              )}
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
              <div style={{ flex: 1 }}>
                <span>Office</span>
                {editingContact ? (
                  <input
                    value={officeInput}
                    onChange={(e) => setOfficeInput(e.target.value)}
                    placeholder="e.g. Engineering Block, Room 4B"
                    maxLength={160}
                    style={{
                      width: '100%', background: 'var(--field-bg)', border: '1px solid var(--border)',
                      borderRadius: 6, padding: '6px 10px', color: 'var(--text)', fontSize: 13, marginTop: 4,
                    }}
                  />
                ) : (
                  <strong style={me?.officeLocation ? undefined : { color: 'var(--muted)' }}>
                    {me?.officeLocation || 'Not set'}
                  </strong>
                )}
              </div>
            </div>
            <div className="contact-row">
              <Clock3 size={16} />
              <div style={{ flex: 1 }}>
                <span>Consultation Hours</span>
                {editingContact ? (
                  <input
                    value={hoursInput}
                    onChange={(e) => setHoursInput(e.target.value)}
                    placeholder="e.g. Mon/Wed 14:00 – 16:00"
                    maxLength={160}
                    style={{
                      width: '100%', background: 'var(--field-bg)', border: '1px solid var(--border)',
                      borderRadius: 6, padding: '6px 10px', color: 'var(--text)', fontSize: 13, marginTop: 4,
                    }}
                  />
                ) : (
                  <strong style={me?.consultationHours ? undefined : { color: 'var(--muted)' }}>
                    {me?.consultationHours || 'Not set'}
                  </strong>
                )}
              </div>
            </div>
            {contactError && (
              <p style={{ color: 'var(--danger)', fontSize: 12, margin: '8px 0 0' }}>{contactError}</p>
            )}
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

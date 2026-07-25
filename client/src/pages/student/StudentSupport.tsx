import { useEffect, useState } from 'react';
import {
  Bell,
  CircleHelp,
  Copy,
  GraduationCap,
  Mail,
  Monitor,
  Settings,
  Shield,
  Sparkles,
  Users,
  MessageSquareText,
  RefreshCcw,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, AuthenticatedUser, AcademicPeriod } from '../../types';
import { api } from '../../api';
import { getStudentInitials, studentSidebarItems } from './studentPortal';
import { Modal } from '../../components/Modal';

type SupportCategory = 'grades' | 'courses' | 'account' | 'technical';

export function StudentSupportScreen({
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
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);
  const [category, setCategory] = useState<SupportCategory>('grades');
  const [subject, setSubject] = useState('');
  const [details, setDetails] = useState('');
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [loadErrors, setLoadErrors] = useState<string[]>([]);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

    const loadData = () => {
    setLoadErrors([]);
    Promise.allSettled([
      api.me().then(setMe).catch(() => setLoadErrors((prev) => [...prev, 'profile'])),
      api.activePeriod().then(setActivePeriod).catch(() => setLoadErrors((prev) => [...prev, 'academic period'])),
    ]);
  };

  useEffect(() => {
    loadData();
  }, []);

  const displayName = me?.fullName ?? 'Student';
  const initials = getStudentInitials(displayName);

  const SUPPORT_PROFILES: Record<SupportCategory, { title: string; description: string; contact: string }> = {
  grades: {
    title: 'Grade question',
    description: 'Use this if a mark looks incorrect, missing, or unsubmitted.',
    contact: 'lecturer + course coordinator',
  },
  courses: {
    title: 'Course enrollment',
    description: 'Use this for timetable, enrollment, or module access problems.',
    contact: 'registry office',
  },
  account: {
    title: 'Account access',
    description: 'Use this for login issues, locked accounts, or password recovery.',
    contact: 'student support desk',
  },
  technical: {
    title: 'Technical issue',
    description: 'Use this for broken pages, uploads, or browser problems.',
    contact: 'platform support',
  },
};

const categoryKeywords: Record<SupportCategory, string[]> = {
  grades:    ['grade', 'mark', 'score', 'transcript', 'gpa'],
    courses:   ['course', 'enroll', 'enrolment', 'module', 'timetable', 'class'],
    account:   ['account', 'login', 'password', 'lock', 'access', 'sign in'],
    technical: ['technical', 'bug', 'broken', 'upload', 'browser', 'error', 'page'],
  };
  const matchedCategory = (Object.entries(categoryKeywords) as [SupportCategory, string[]][]).find(
    ([, keywords]) => keywords.some((kw) => search.toLowerCase().includes(kw)),
  )?.[0] ?? null;
  const displayCategory = matchedCategory ?? category;
  const supportProfile = SUPPORT_PROFILES[category];
 
 const displayProfile = SUPPORT_PROFILES[displayCategory];
  const copyRequest = async () => {
    const request = [
      `Student: ${displayName}`,
      `Student ID: ${me?.studentId ?? '--'}`,
      `Category: ${supportProfile.title}`,
      `Subject: ${subject || '[no subject]'}`,
      '',
      details || '[no details entered]',
    ].join('\n');

    try {
      await navigator.clipboard.writeText(request);
      setStatusMessage('Support request copied to your clipboard.');
    } catch {
      setStatusMessage('Could not access the clipboard. Copy the request manually.');
    }
  };

  const mailtoSubject = encodeURIComponent(subject || `${supportProfile.title} request`);
  const mailtoBody = encodeURIComponent(
    [
      `Student: ${displayName}`,
      `Student ID: ${me?.studentId ?? '--'}`,
      `Department: ${me?.department ?? 'Student'}`,
      `Category: ${supportProfile.title}`,
      '',
      details || 'Describe your issue here.',
    ].join('\n'),
  );

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT SUPPORT"
      searchPlaceholder="Search support topics..."
      searchValue={search}
      onSearchChange={setSearch}
      sidebarItems={studentSidebarItems}
      footerAction={() => onNavigate('student-dashboard')}
      footerActionClassName="deploy-btn"
      footerActionLabel="Back to Overview"
      footerActionIcon={<Sparkles size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.role ?? 'STUDENT' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            aria-label="Notifications"
            onClick={() => openNotice('Notifications', `You're currently viewing the ${displayProfile.title} category. Requests are routed to ${displayProfile.contact}.`)}
          >
            <Bell size={20} />
          </button>
          <button
            className="icon-chip"
            aria-label="Console"
            onClick={() => openNotice('Console Status', `Active period: ${activePeriod?.name ?? 'None'}.`)}
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
      shellClassName="student-shell student-shell--support"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-page student-support-page">
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
            <button type="button" className="primary-mini" onClick={loadData}>
              <RefreshCcw size={14} /> Retry
            </button>
          </div>
        )}
        <header className="student-page-hero student-hero-support">
          <div>
            <div className="student-page-kicker">HELP CENTER</div>
            <h1>Student Support Desk</h1>
            <p>
              Use this desk to raise a question about grades, courses, access, or technical issues.
              Each request is formatted for a proper support handoff.
            </p>
          </div>
          <div className="student-page-hero-badge">
            <span>ACTIVE PERIOD</span>
            <strong>{activePeriod?.name ?? 'No active period'}</strong>
          </div>
        </header>

        <section className="student-support-grid">
          <div className="panel-card student-support-card">
            <div className="panel-heading student-panel-heading">
              <div className="section-inline">
                <CircleHelp size={18} />
                <h3>OPEN A REQUEST</h3>
              </div>
              <div className="live-chip"><span />GUIDED</div>
            </div>

            <div className="student-support-summary">
              <div>
                <span>RESPONSE WINDOW</span>
                <strong>24 - 48 HOURS</strong>
              </div>
              <div>
                <span>CHANNEL</span>
                <strong>{displayProfile.contact}</strong>
              </div>
              <div>
                <span>REQUEST TYPE</span>
                <strong>{displayProfile.title}</strong>
              </div>
            </div>

            <div className="student-support-categories">
              {(
                [
                  ['grades', 'Grades'],
                  ['courses', 'Courses'],
                  ['account', 'Account'],
                  ['technical', 'Technical'],
                ] as Array<[SupportCategory, string]>
              ).map(([value, label]) => (
                <button
                  key={value}
                  type="button"
                  className={`student-support-chip ${(displayCategory === value) ? 'active' : ''}`}
                  onClick={() => { setCategory(value); setSearch(''); }}
                >
                  {label}
                </button>
              ))}
            </div>

            <div className="student-support-intro">
              <strong>{displayProfile.title}</strong>
              <p>{displayProfile.description}</p>
              <span>Best routed to {displayProfile.contact}.</span>
            </div>

            <div className="grading-field">
              <label>Subject</label>
              <div className="grading-input-wrap">
                <MessageSquareText size={16} />
                <input
                  value={subject}
                  onChange={(e) => setSubject(e.target.value)}
                  placeholder="Short summary of the issue"
                />
              </div>
            </div>

            <div className="grading-field">
              <label>Details</label>
              <textarea
                rows={6}
                value={details}
                onChange={(e) => setDetails(e.target.value)}
                placeholder="Add the course name, what happened, and any error message you saw..."
              />
            </div>

            {statusMessage && <div className="student-support-status">{statusMessage}</div>}

            <div className="student-support-actions">
              <button className="primary-mini" type="button" onClick={copyRequest}>
                <Copy size={16} />
                Copy Request
              </button>
              <button
                className="outlined-btn student-support-clear"
                type="button"
                onClick={() => {
                  setSubject('');
                  setDetails('');
                  setStatusMessage('Support request cleared.');
                }}
              >
                Clear
              </button>
              <a
                className="outlined-btn student-support-mail"
                href={`mailto:student-support@rasac.edu?subject=${mailtoSubject}&body=${mailtoBody}`}
              >
                <Mail size={16} />
                Email Support
              </a>
            </div>
          </div>

          <aside className="student-support-side">
            <div className="panel-card student-support-info">
              <div className="panel-heading">
                <h3>HELP CHANNELS</h3>
                <Users size={18} />
              </div>
              <div className="student-help-card">
                <strong>Student Support Desk</strong>
                <p>student-support@rasac.edu</p>
              </div>
              <div className="student-help-card">
                <strong>Registry Office</strong>
                <p>registry@rasac.edu</p>
              </div>
              <div className="student-help-card">
                <strong>Academic Office Hours</strong>
                <p>Mon to Fri, 09:00 - 15:00</p>
              </div>
            </div>

            <div className="panel-card student-support-info">
              <div className="panel-heading">
                <h3>FAST ANSWERS</h3>
                <Shield size={18} />
              </div>
              <div className="student-help-card compact">
                <strong>Need a grade review?</strong>
                <p>Use the grades page to check the latest score and export your transcript.</p>
              </div>
              <div className="student-help-card compact">
                <strong>Need class details?</strong>
                <p>Go to Courses for lecturer names, classmates, and your active module list.</p>
              </div>
              <div className="student-help-card compact">
                <strong>Need account help?</strong>
                <p>If login is blocked, send your student ID and a description of the issue.</p>
              </div>
            </div>

            <div className="panel-card student-support-info accent">
              <div className="panel-heading">
                <h3>STUDENT PROFILE</h3>
                <GraduationCap size={18} />
              </div>
              <p style={{ marginTop: 0, color: 'var(--muted)' }}>
                {displayName} from {me?.department ?? 'Student Services'}.
              </p>
            </div>

            <div className="panel-card student-support-info">
              <div className="panel-heading">
                <h3>QUICK TIPS</h3>
                <Shield size={18} />
              </div>
              <div className="student-help-card compact">
                <strong>Be specific</strong>
                <p>Include the course code, a brief symptom, and any error text you saw.</p>
              </div>
              <div className="student-help-card compact">
                <strong>Use grades for mark issues</strong>
                <p>Grade-related concerns are routed faster when sent from the grades category.</p>
              </div>
            </div>
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

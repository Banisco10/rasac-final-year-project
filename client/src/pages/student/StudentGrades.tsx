import { useEffect, useMemo, useState } from 'react';
import {
  Bell,
  DownloadCloud,
  Monitor,
  RefreshCcw,
  Settings,
  Shield,
  Award,
  BookOpen,
  CalendarDays,
  TrendingUp,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, Grade, AuthenticatedUser, AcademicPeriod } from '../../types';
import { api } from '../../api';
import { getStudentInitials, studentSidebarItems } from './studentPortal';
import { Modal } from '../../components/Modal';

type Transcript = {
  studentId: number;
  gpa: number;
  totalCredits: number;
  grades: Array<Grade & { course: { id: number; code: string; title: string; credits: number } | null }>;
};

function gradeTone(status: Grade['status']) {
  if (status === 'APPROVED') return 'ok';
  if (status === 'SUBMITTED') return 'warn';
  if (status === 'REJECTED') return 'deny';
  return 'info';
}

function distributionForGrades(grades: Grade[]) {
  return [
    { label: 'A', count: grades.filter((grade) => grade.grade.startsWith('A')).length },
    { label: 'B+', count: grades.filter((grade) => grade.grade.startsWith('B')).length },
    { label: 'B', count: grades.filter((grade) => grade.grade.startsWith('B')).length },
    { label: 'C+', count: grades.filter((grade) => grade.grade.startsWith('C')).length },
    { label: 'C', count: grades.filter((grade) => grade.grade.startsWith('C')).length },
    { label: 'D+', count: grades.filter((grade) => grade.grade.startsWith('D')).length },
    { label: 'D', count: grades.filter((grade) => grade.grade.startsWith('D')).length },
    { label: 'F', count: grades.filter((grade) => grade.grade.startsWith('F')).length },
  ];
}

export function StudentGradesScreen({
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
  const [grades, setGrades] = useState<Grade[]>([]);
  const [transcript, setTranscript] = useState<Transcript | null>(null);
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);
  const [search, setSearch] = useState('');
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [transcriptLoaded, setTranscriptLoaded] = useState(false);
  const [meLoaded, setMeLoaded] = useState(false);
  const [gradesLoaded, setGradesLoaded] = useState(false);
  const [periodLoaded, setPeriodLoaded] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [loadErrors, setLoadErrors] = useState<string[]>([]);

  const loadData = () => {
  setRefreshing(true);
  setLoadErrors([]);

  Promise.allSettled([
    api.me().then(setMe)
      .catch(() => setLoadErrors((prev) => [...prev, 'profile']))
      .finally(() => setMeLoaded(true)),
    api.myGrades().then(setGrades)
      .catch(() => setLoadErrors((prev) => [...prev, 'grades']))
      .finally(() => setGradesLoaded(true)),
    api.transcript().then((data) => setTranscript(data as unknown as Transcript))
      .catch(() => setLoadErrors((prev) => [...prev, 'transcript']))
      .finally(() => setTranscriptLoaded(true)),
    api.activePeriod().then(setActivePeriod)
      .catch(() => setLoadErrors((prev) => [...prev, 'academic period']))
      .finally(() => setPeriodLoaded(true)),
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
  const displayName = me?.fullName ?? 'Student';
  const initials = getStudentInitials(displayName);

  const transcriptGrades: Array<Grade & { course: Transcript['grades'][number]['course'] }> = transcript
    ? transcript.grades
    : grades.map((grade) => ({ ...grade, course: null }));

  const orderedGrades = useMemo(
    () => {
      const sorted = [...transcriptGrades].sort(
        (a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime(),
      );
      if (!search.trim()) return sorted;
      const term = search.toLowerCase();
      return sorted.filter(
        (g) =>
          (g.course?.title ?? '').toLowerCase().includes(term) ||
          (g.course?.code ?? '').toLowerCase().includes(term) ||
          g.grade.toLowerCase().includes(term) ||
          g.status.toLowerCase().includes(term),
      );
    },
    [transcriptGrades, search],
  );

  const counts = useMemo(() => ({
    total: orderedGrades.length,
    approved: orderedGrades.filter((grade) => grade.status === 'APPROVED').length,
    submitted: orderedGrades.filter((grade) => grade.status === 'SUBMITTED').length,
    average: orderedGrades.length
      ? Math.round(orderedGrades.reduce((sum, grade) => sum + grade.score, 0) / orderedGrades.length)
      : null,
  }), [orderedGrades]);

  const distribution = distributionForGrades(orderedGrades);

  const exportTranscript = () => {
    if (!transcript) return;
    const blob = new Blob([JSON.stringify(transcript, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = `transcript-${me?.studentId ?? 'student'}.json`;
    anchor.click();
    URL.revokeObjectURL(url);
  };

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="GRADE TRANSCRIPT"
      searchPlaceholder="Search grade records..."
      searchValue={search}
      onSearchChange={setSearch}
      sidebarItems={studentSidebarItems}
      footerAction={exportTranscript}
      footerActionClassName="deploy-btn"
      footerActionLabel="Export Transcript"
      footerActionIcon={<DownloadCloud size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.role ?? 'STUDENT' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            aria-label="Notifications"
            onClick={() => openNotice('Notifications', `You have ${counts.submitted} grade${counts.submitted === 1 ? '' : 's'} awaiting approval.`)}
          >
            <Bell size={20} />
          </button>
          <button
            className="icon-chip"
            aria-label="Console"
            onClick={() => openNotice('Console Status', `Active period: ${activePeriod?.name ?? 'None'}. ${counts.total} grade record${counts.total === 1 ? '' : 's'} on file.`)}
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
      shellClassName="student-shell student-shell--grades"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-page student-grades-page">
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
        <header className="student-page-hero student-hero-grades">
          <div>
            <div className="student-page-kicker">TRANSCRIPT RIBBON</div>
            <h1>My Grades</h1>
            <p>
              A student-first transcript view that surfaces your GPA, total credits, and grade history
              without the administrative noise of the other portals.
            </p>
          </div>
          <div className="student-page-hero-badge">
            <span>ACTIVE PERIOD</span>
            <strong>{activePeriod?.name ?? 'No active period'}</strong>
          </div>
        </header>

        <div className="student-insight-grid">
          <article className="student-insight-card">
            <span>CUMULATIVE GPA</span>
            <strong>{transcript ? transcript.gpa.toFixed(2) : '--'}</strong>
            <p>Based on your current transcript.</p>
          </article>
          <article className="student-insight-card">
            <span>TOTAL CREDITS</span>
            <strong>{transcriptLoaded ? (transcript?.totalCredits ?? 0) : '—'}</strong>
            <p>Credits completed and recorded.</p>
          </article>
          <article className="student-insight-card">
            <span>APPROVED GRADES</span>
            <strong>{counts.approved}</strong>
            <p>Finalized by the lecturer.</p>
          </article>
          <article className="student-insight-card accent">
            <span>SUBMITTED</span>
            <strong>{counts.submitted}</strong>
            <p>{counts.average !== null ? `Average score ${counts.average}%` : 'No grade averages yet'}</p>
          </article>
        </div>

        <section className="student-grades-layout">
          <div className="panel-card student-transcript-card">
            <div className="panel-heading student-panel-heading">
              <div className="section-inline">
                <Award size={18} />
                <h3>TRANSCRIPT SUMMARY</h3>
              </div>
              <button className="view-btn" type="button" onClick={loadData} disabled={refreshing}>
                <RefreshCcw size={16} className={refreshing ? 'spinning' : ''} />
                Refresh
              </button>
            </div>

            <div className="student-transcript-banner">
              <div>
                <span>Latest transcript snapshot</span>
                <strong>{displayName}</strong>
              </div>
              <div>
                <span>Student ID</span>
                <strong>{me?.studentId ?? '--'}</strong>
              </div>
              <div>
                <span>Period</span>
                <strong>{activePeriod?.name ?? 'No active period'}</strong>
              </div>
            </div>

            <div className="student-distribution">
              {distribution.map((item) => (
                <div className="student-distribution-item" key={item.label}>
                  <span>{item.label}</span>
                  <div className="student-distribution-bar">
                    <div style={{ width: `${Math.min(100, item.count * 24)}%` }} />
                  </div>
                  <strong>{item.count}</strong>
                </div>
              ))}
            </div>

            <div className="student-grade-table">
              <div className="student-grade-head">
                <span>COURSE</span>
                <span>STATUS</span>
                <span>SCORE</span>
                <span>MARK</span>
                <span>SUBMITTED</span>
              </div>
              {orderedGrades.length === 0 && (
                <div className="student-empty-state">
                  <strong>No grade records found.</strong>
                  <p>Your lecturer has not submitted grades yet.</p>
                </div>
              )}
              {orderedGrades.map((grade) => (
                <div className="student-grade-row" key={grade.id}>
                  <div>
                    <strong>{grade.course?.title ?? `Course #${grade.courseId}`}</strong>
                    <span>{grade.course?.code ?? `#${grade.courseId}`}</span>
                  </div>
                  <span className={`student-grade-pill ${gradeTone(grade.status)}`}>{grade.status}</span>
                  <span className="student-grade-score">{grade.score}%</span>
                  <strong className="student-grade-mark">{grade.grade}</strong>
                  <span>{new Date(grade.submittedAt).toLocaleDateString()}</span>
                </div>
              ))}
            </div>
          </div>

          <aside className="panel-card student-grade-sidebar">
            <div className="panel-heading">
              <h3>GRADE NOTES</h3>
              <Shield size={18} />
            </div>
            <div className="student-grade-notes">
              <div className="student-note-card">
                <CalendarDays size={18} />
                <div>
                  <strong>Submission Timeline</strong>
                  <p>Grades are shown in reverse chronological order for clarity.</p>
                </div>
              </div>
              <div className="student-note-card">
                <TrendingUp size={18} />
                <div>
                  <strong>Performance Trend</strong>
                  <p>Watch for rising scores and approved submissions.</p>
                </div>
              </div>
              <div className="student-note-card">
                <BookOpen size={18} />
                <div>
                  <strong>Transcript Export</strong>
                  <p>Use the export button to copy your transcript JSON locally.</p>
                </div>
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

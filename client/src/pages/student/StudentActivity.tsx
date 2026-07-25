import { useEffect, useMemo, useState } from 'react';
import {
  Bell,
  Clock3,
  Filter,
  ChevronLeft,
  ChevronRight,
  History,
  Monitor,
  RefreshCcw,
  Settings,
  Shield,
  Sparkles,
  BookOpen,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, AuditLog, AuthenticatedUser, Grade, AcademicPeriod } from '../../types';
import { api } from '../../api';
import { getStudentInitials, studentSidebarItems } from './studentPortal';
import { Modal } from '../../components/Modal';


type Transcript = {
  studentId: number;
  gpa: number;
  totalCredits: number;
  grades: Array<Grade & { course: { id: number; code: string; title: string; credits: number } | null }>;
};

function toneForOutcome(outcome: AuditLog['outcome']) {
  if (outcome === 'GRANTED') return 'success';
  if (outcome === 'DENIED_ROLE' || outcome === 'DENIED_RELATIONSHIP' || outcome === 'DENIED_CONTEXT') return 'warn';
  return 'deny';
}

export function StudentActivityScreen({
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
  const [activity, setActivity] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState('');
  const [outcomeFilter, setOutcomeFilter] = useState<'ALL' | AuditLog['outcome']>('ALL');
  const [page, setPage] = useState(1);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [transcript, setTranscript] = useState<Transcript | null>(null);
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [loadErrors, setLoadErrors] = useState<string[]>([]);

  const loadData = () => {
  setRefreshing(true);
  setLoadErrors([]);
  Promise.allSettled([
    api.me().then(setMe).catch(() => setLoadErrors((prev) => [...prev, 'profile'])),
    api.auditMy().then(setActivity).catch(() => setLoadErrors((prev) => [...prev, 'activity log'])),
    api.myGrades().then(setGrades).catch(() => setLoadErrors((prev) => [...prev, 'grades'])),
    api.transcript().then((data) => setTranscript(data as unknown as Transcript)).catch(() => setLoadErrors((prev) => [...prev, 'transcript'])),
    api.activePeriod().then(setActivePeriod).catch(() => setLoadErrors((prev) => [...prev, 'academic period'])),
  ]).finally(() => setRefreshing(false));
};

  useEffect(() => 
    {
      loadData();
    },
    []);


  const PAGE_SIZE = 10;
  
  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  useEffect(() => {
    setPage(1);
  }, [search, outcomeFilter]);

  const displayName = me?.fullName ?? 'Student';
  const initials = getStudentInitials(displayName);
  
  const filtered = useMemo(
    () =>
      activity.filter((log) => {
        if (outcomeFilter !== 'ALL' && log.outcome !== outcomeFilter) {
          return false;
        }

        if (!search.trim()) {
          return true;
        }

        const term = search.toLowerCase();
        return [log.action, log.resource, log.requestPath, log.denyReason, log.resourceId]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(term));
      }),
    [activity, outcomeFilter, search],
  );
  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const paginated = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);
  const pageStart = (page - 1) * PAGE_SIZE;
  const pageEnd = Math.min(pageStart + PAGE_SIZE, filtered.length);
  const displayStart = filtered.length > 0 ? pageStart + 1 : 0;

  const counts = useMemo(() => ({
    total: activity.length,
    granted: activity.filter((log) => log.outcome === 'GRANTED').length,
    denied: activity.filter((log) => log.outcome !== 'GRANTED').length,
    latest: activity[0] ?? null,
  }), [activity]);

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

  const countsAlert = useMemo(() => ({
      total: orderedGrades.length,
      approved: orderedGrades.filter((grade) => grade.status === 'APPROVED').length,
      submitted: orderedGrades.filter((grade) => grade.status === 'SUBMITTED').length,
      average: orderedGrades.length
        ? Math.round(orderedGrades.reduce((sum, grade) => sum + grade.score, 0) / orderedGrades.length)
        : null,
    }), [orderedGrades]);

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT ACTIVITY"
      searchPlaceholder="Search your activity..."
      searchValue={search}
      onSearchChange={setSearch}
      sidebarItems={studentSidebarItems}
      footerAction={() => onNavigate('student-support')}
      footerActionClassName="deploy-btn"
      footerActionLabel="Need Help?"
      footerActionIcon={<Sparkles size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.role ?? 'STUDENT' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            aria-label="Notifications"
            onClick={() => openNotice('Notifications', `You have ${counts.denied} event${counts.denied === 1 ? '' : 's'} that needed policy review.`)}
          >
            <Bell size={20} />
          </button>
          <button
            className="icon-chip"
            aria-label="Console"
            onClick={() => openNotice('Console Status', `${counts.total} total activity event${counts.total === 1 ? '' : 's'} on record.`)}
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
      shellClassName="student-shell student-shell--activity"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-page student-activity-page">
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
        <header className="student-page-hero student-hero-activity">
          <div>
            <div className="student-page-kicker">JOURNEY LOG</div>
            <h1>My Activity</h1>
            <p>
              A personal timeline of what your account has been doing across the student portal,
              written in a calmer tone than the administrative audit console.
            </p>
          </div>
          <div className="student-page-hero-badge">
            <span>RECENT EVENT</span>
            <strong>{counts.latest ? counts.latest.outcome : 'No activity'}</strong>
          </div>
        </header>

        <div className="student-insight-grid">
          <article className="student-insight-card">
            <span>TOTAL EVENTS</span>
            <strong>{counts.total}</strong>
            <p>Your most recent account actions.</p>
          </article>
          <article className="student-insight-card">
            <span>ALLOWED</span>
            <strong>{counts.granted}</strong>
            <p>Requests that completed successfully.</p>
          </article>
          <article className="student-insight-card">
            <span>BLOCKED OR WARNED</span>
            <strong>{counts.denied}</strong>
            <p>Events that needed policy review.</p>
          </article>
          <article className="student-insight-card accent">
            <span>LAST SEEN</span>
            <strong>{counts.latest ? new Date(counts.latest.timestamp).toLocaleDateString() : '--'}</strong>
            <p>{counts.latest ? new Date(counts.latest.timestamp).toLocaleTimeString() : 'Waiting for activity'}</p>
          </article>
        </div>

        <section className="panel-card student-activity-filters">
          <div className="panel-heading student-panel-heading">
            <div className="section-inline">
              <Filter size={18} />
              <h3>FILTER ACTIVITY</h3>
            </div>
            <button className="view-btn" type="button" onClick={loadData} disabled={refreshing}>
              <RefreshCcw size={16} className={refreshing ? 'spinning' : ''} />
              Refresh
            </button>
          </div>
          <div className="grading-form-grid student-activity-filter-grid">
            <div className="grading-field">
              <label>Outcome</label>
              <div className="grading-select-wrap">
                <select value={outcomeFilter} onChange={(e) => setOutcomeFilter(e.target.value as typeof outcomeFilter)}>
                  <option value="ALL">All outcomes</option>
                  <option value="GRANTED">Granted</option>
                  <option value="DENIED_ROLE">Denied - Role</option>
                  <option value="DENIED_RELATIONSHIP">Denied - Relationship</option>
                  <option value="DENIED_CONTEXT">Denied - Context</option>
                  <option value="DENIED_SOD">Denied - SoD</option>
                  <option value="ERROR">Errors</option>
                </select>
              </div>
            </div>
          </div>
        </section>

        <section className="student-activity-layout">
          <div className="panel-card student-journey-card">
            <div className="panel-heading student-panel-heading">
              <div className="section-inline">
                <History size={18} />
                <h3>ACTIVITY TIMELINE</h3>
              </div>
              <div className="live-chip"><span />LIVE FEED</div>
            </div>

            <div className="student-journey-feed">
              {paginated.length === 0 ? (
                <div className="student-empty-state">
                  <strong>No activity matches the filters.</strong>
                  <p>Try a different search term or outcome filter.</p>
                </div>
              ) : (
                paginated.map((log) => (
                  <article className={`student-journey-item ${toneForOutcome(log.outcome)}`} key={log.id}>
                    <div className="student-journey-marker">
                      <span />
                    </div>
                    <div className="student-journey-copy">
                      <div className="student-journey-head">
                        <strong>{log.action}</strong>
                        <time>{new Date(log.timestamp).toLocaleString()}</time>
                      </div>
                      <p>{log.resource}{log.resourceId ? ` #${log.resourceId}` : ''}</p>
                      <div className="student-journey-tags">
                        <span>{log.outcome}</span>
                        {log.requestPath && <span>{log.requestPath}</span>}
                        {log.denyReason && <span>{log.denyReason}</span>}
                      </div>
                      <div className="student-journey-meta">
                        <span><Clock3 size={14} /> {log.ipAddress ?? 'local'}</span>
                        <span><Shield size={14} /> {log.userAgent ? 'Tracked session' : 'No user agent'}</span>
                      </div>
                    </div>
                  </article>
                ))
              )}
              {filtered.length > 0 && (
                <div className="audit-pagination">
                  <div>
                    Showing {displayStart}-{pageEnd} of {filtered.length} matching event{filtered.length === 1 ? '' : 's'}.
                    {filtered.length !== activity.length && ` ${activity.length} total.`}
                  </div>
                  <div className="audit-pagination-controls">
                    <button
                      type="button"
                      className="icon-chip"
                      aria-label="Previous activity page"
                      disabled={page === 1}
                      onClick={() => setPage((p) => Math.max(1, p - 1))}
                    >
                      <ChevronLeft size={18} />
                    </button>
                    <span>Page {page} of {totalPages}</span>
                    <button
                      type="button"
                      className="icon-chip"
                      aria-label="Next activity page"
                      disabled={page === totalPages}
                      onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    >
                      <ChevronRight size={18} />
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>

          <aside className="panel-card student-activity-sidebar">
            <div className="panel-heading">
              <h3>QUICK READ</h3>
              <BookOpen size={18} />
            </div>
            <div className="student-activity-notes">
              <div className="student-note-card">
                <strong>What this is</strong>
                <p>Your own account history, not the institution-wide admin audit log.</p>
              </div>
              <div className="student-note-card">
                <strong>What to look for</strong>
                <p>Check the request path, resource, and deny reason when something feels off.</p>
              </div>
              <div className="student-note-card">
                <strong>Need help?</strong>
                <p>Use the support page if you spot an account issue or unexpected denial.</p>
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

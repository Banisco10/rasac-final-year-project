import { useEffect, useMemo, useState } from 'react';
import {
  Bell,
  Clock3,
  Filter,
  History,
  Monitor,
  RefreshCcw,
  Settings,
  Shield,
  Search,
  Sparkles,
  BookOpen,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { View, AuditLog, AuthenticatedUser } from '../../types';
import { api } from '../../api';
import { getStudentInitials, studentSidebarItems } from './studentPortal';

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
  const [activity, setActivity] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState('');
  const [outcomeFilter, setOutcomeFilter] = useState<'ALL' | AuditLog['outcome']>('ALL');

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.auditMy().then(setActivity).catch(console.error);
  }, []);

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

  const counts = useMemo(() => ({
    total: activity.length,
    granted: activity.filter((log) => log.outcome === 'GRANTED').length,
    denied: activity.filter((log) => log.outcome !== 'GRANTED').length,
    latest: activity[0] ?? null,
  }), [activity]);

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT ACTIVITY"
      searchPlaceholder="Search your activity..."
      sidebarItems={studentSidebarItems}
      footerAction={() => onNavigate('student-support')}
      footerActionClassName="deploy-btn"
      footerActionLabel="Need Help?"
      footerActionIcon={<Sparkles size={16} />}
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
      shellClassName="student-shell student-shell--activity"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-page student-activity-page">
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
            <button className="view-btn" type="button" onClick={() => api.auditMy().then(setActivity).catch(console.error)}>
              <RefreshCcw size={16} />
              Refresh
            </button>
          </div>
          <div className="grading-form-grid student-activity-filter-grid">
            <div className="grading-field">
              <label>Search</label>
              <div className="grading-input-wrap">
                <Search size={16} />
                <input
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  placeholder="Action, resource, path, or reason"
                />
              </div>
            </div>
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
              {filtered.length === 0 ? (
                <div className="student-empty-state">
                  <strong>No activity matches the filters.</strong>
                  <p>Try a different search term or outcome filter.</p>
                </div>
              ) : (
                filtered.map((log) => (
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
    </Shell>
  );
}

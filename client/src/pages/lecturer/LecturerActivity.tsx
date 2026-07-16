import { useEffect, useMemo, useState } from 'react';
import {
  LayoutDashboard,
  FileText,
  NotebookPen,
  UserRound,
  Bell,
  History,
  RefreshCcw,
  Shield,
  Filter,
  Clock3,
  Search,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { AuditLog, AuthenticatedUser, View, NavItem } from '../../types';
import { api } from '../../api';

type ActivityTone = 'success' | 'warn' | 'deny' | 'info';

function toneForLog(log: AuditLog): ActivityTone {
  if (log.outcome === 'GRANTED') return 'success';
  if (log.outcome === 'ERROR') return 'deny';
  if (log.outcome === 'DENIED_SOD') return 'deny';
  if (log.outcome === 'DENIED_CONTEXT' || log.outcome === 'DENIED_RELATIONSHIP' || log.outcome === 'DENIED_ROLE') return 'warn';
  return 'info';
}

export function LecturerActivityScreen({
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
  const [activity, setActivity] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState('');
  const [outcomeFilter, setOutcomeFilter] = useState<'ALL' | AuditLog['outcome']>('ALL');

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.auditMy().then(setActivity).catch(console.error);
  }, []);

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName
    .split(' ')
    .map((name) => name[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  const filteredActivity = useMemo(
    () =>
      activity.filter((log) => {
        if (outcomeFilter !== 'ALL' && log.outcome !== outcomeFilter) {
          return false;
        }

        if (!search.trim()) {
          return true;
        }

        const term = search.toLowerCase();
        return [
          log.action,
          log.resource,
          log.resourceId,
          log.requestPath,
          log.denyReason,
        ]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(term));
      }),
    [activity, outcomeFilter, search],
  );

  const counts = useMemo(() => ({
    total: activity.length,
    granted: activity.filter((log) => log.outcome === 'GRANTED').length,
    denied: activity.filter((log) => log.outcome !== 'GRANTED').length,
    recent: activity.slice(0, 1)[0] ?? null,
  }), [activity]);

  return (
    <Shell
      activeView="lecturer-activity"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="LECTURER ACTIVITY"
      searchPlaceholder="Search your activity..."
      sidebarItems={sidebarItems}
      footerAction={() => onNavigate('lecturer-dashboard')}
      footerActionClassName="deploy-btn"
      footerActionLabel="Back to Dashboard"
      footerActionIcon={<Shield size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Lecturer' }}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications">
            <Bell size={20} />
          </button>
          <button className="icon-chip" aria-label="History">
            <History size={20} />
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
      <section className="page-stack portal-page lecturer-page">
        <div className="portal-banner warning">
          <div>
            <strong>Personal activity log</strong>
            <p>This view only shows actions performed by your lecturer account, not the admin audit console.</p>
          </div>
          <div className="status-pill open">PERSONAL</div>
        </div>

        <div className="course-metrics">
          <div className="course-metric-card">
            <div className="course-metric-label">TOTAL EVENTS</div>
            <div className="course-metric-value">{counts.total}</div>
            <div className="course-metric-sub">Your recent system activity</div>
          </div>
          <div className="course-metric-card">
            <div className="course-metric-label">GRANTED</div>
            <div className="course-metric-value">{counts.granted}</div>
            <div className="course-metric-sub">Allowed lecturer actions</div>
          </div>
          <div className="course-metric-card">
            <div className="course-metric-label">DENIED / WARNED</div>
            <div className="course-metric-value">{counts.denied}</div>
            <div className="course-metric-sub">Policy checks and blocked attempts</div>
          </div>
          <div className="course-metric-card status-card">
            <div className="course-metric-label">LATEST EVENT</div>
            <div className="status-line">
              <span className="status-dot warning" />
              {counts.recent ? counts.recent.outcome : 'No activity yet'}
            </div>
            <div className="course-metric-sub upper">
              {counts.recent ? new Date(counts.recent.timestamp).toLocaleString() : 'Awaiting activity'}
            </div>
          </div>
        </div>

        <section className="panel-card" style={{ padding: 18 }}>
          <div className="panel-heading" style={{ marginBottom: 16 }}>
            <h3>Activity Filters</h3>
            <Filter size={18} />
          </div>
          <div className="grading-form-grid" style={{ alignItems: 'end' }}>
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

        <section className="grading-history">
          <div className="panel-heading" style={{ padding: '16px 18px 0' }}>
            <h3>My Activity Log</h3>
            <button
              type="button"
              className="view-btn"
              onClick={() => api.auditMy().then(setActivity).catch(console.error)}
            >
              <RefreshCcw size={16} />
              Refresh
            </button>
          </div>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Timestamp</th>
                  <th>Action</th>
                  <th>Resource</th>
                  <th>Outcome</th>
                  <th>Path</th>
                  <th>Reason</th>
                </tr>
              </thead>
              <tbody>
                {filteredActivity.length === 0 ? (
                  <tr>
                    <td colSpan={6} style={{ color: 'var(--muted)', textAlign: 'center', padding: 16 }}>
                      No lecturer activity matches the current filters.
                    </td>
                  </tr>
                ) : (
                  filteredActivity.map((log) => (
                    <tr key={log.id}>
                      <td>
                        <div style={{ display: 'grid', gap: 4 }}>
                          <span style={{ color: '#dce5f2' }}>{new Date(log.timestamp).toLocaleString()}</span>
                          <span style={{ color: 'var(--muted)', fontSize: 12 }}>
                            <Clock3 size={14} style={{ verticalAlign: 'text-bottom', marginRight: 6 }} />
                            {log.ipAddress ?? 'local'}
                          </span>
                        </div>
                      </td>
                      <td>{log.action}</td>
                      <td>{log.resource}{log.resourceId ? ` #${log.resourceId}` : ''}</td>
                      <td>
                        <span className={`pill ${toneForLog(log) === 'success' ? 'ok' : toneForLog(log) === 'warn' ? 'warn' : 'deny'}`}>
                          {log.outcome}
                        </span>
                      </td>
                      <td style={{ color: 'var(--muted)' }}>{log.requestPath ?? '--'}</td>
                      <td style={{ color: 'var(--muted)' }}>{log.denyReason ?? '--'}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>
      </section>
    </Shell>
  );
}

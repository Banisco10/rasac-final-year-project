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
  ChevronDown,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import type { AuditLog, AuthenticatedUser, View, NavItem } from '../../types';
import { api } from '../../api';

type ActivityTone = 'success' | 'warn' | 'deny' | 'info';

function toneForLog(log: AuditLog): ActivityTone {
  if (log.outcome === 'GRANTED') return 'success';
  if (log.outcome === 'ERROR') return 'info';
  if (log.outcome === 'DENIED_SOD') return 'deny';
  if (log.outcome === 'DENIED_CONTEXT' || log.outcome === 'DENIED_RELATIONSHIP' || log.outcome === 'DENIED_ROLE') return 'warn';
  return 'deny';
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
  const [headerSearch, setHeaderSearch] = useState('');
  const [activitySearch, setActivitySearch] = useState('');
  const [outcomeFilter, setOutcomeFilter] = useState<'ALL' | AuditLog['outcome']>('ALL');
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [page, setPage] = useState(1);

  const loadActivity = async () => {
    setLoading(true);
    try {
      const [meRes, activityRes] = await Promise.all([api.me(), api.auditMy()]);
      console.log('raw audit log sample:', activityRes[0]);
      setMe(meRes);
      setActivity(activityRes);
      setLoadError(null);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to reach the RASAC server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadActivity();
  }, []);

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName
    .split(' ')
    .map((name) => name[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

    
    const sortedActivity = useMemo(
      () => [...activity].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()),
      [activity]
    );

  const filteredActivity = useMemo(
    () =>
      sortedActivity.filter((log) => {
        if (outcomeFilter !== 'ALL' && log.outcome !== outcomeFilter) {
          return false;
        }

        const localTerm = activitySearch.toLowerCase().trim();
        if (localTerm) {
          const matchesLocalSearch = [
            log.action,
            log.resource,
            log.resourceId,
            log.requestPath,
            log.denyReason,
          ]
            .filter(Boolean)
            .some((value) => String(value).toLowerCase().includes(localTerm));

          if (!matchesLocalSearch) return false;
        }

        const headerTerm = headerSearch.toLowerCase().trim();
        if (!headerTerm) return true;

        return [
          log.action,
          log.resource,
          log.resourceId,
          log.requestPath,
          log.denyReason,
          log.outcome,
          log.ipAddress,
          log.userAgent,
          log.timestamp,
          JSON.stringify(log.metadata ?? {}),
        ]
          .filter(Boolean)
          .some((value) => String(value).toLowerCase().includes(headerTerm));
      }),
    [sortedActivity, outcomeFilter, activitySearch, headerSearch],
  );

  const pageSize = 10;
  const totalPages = Math.max(1, Math.ceil(filteredActivity.length / pageSize));
  const safePage = Math.min(page, totalPages);
  const visibleActivity = filteredActivity.slice((safePage - 1) * pageSize, safePage * pageSize);

  useEffect(() => {
    setPage(1);
  }, [headerSearch, activitySearch, outcomeFilter]);


const counts = useMemo(() => ({
    total: activity.length,
    granted: activity.filter((log) => log.outcome === 'GRANTED').length,
    denied: activity.filter((log) => log.outcome !== 'GRANTED' && log.outcome !== 'ERROR').length,
    errors: activity.filter((log) => log.outcome === 'ERROR').length,
    recent: sortedActivity[0] ?? null,
  }), [activity, sortedActivity]);

  return (
    <Shell
      activeView="lecturer-activity"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="LECTURER ACTIVITY"
      searchPlaceholder="Wide search: outcome, IP, metadata, path..."
      searchValue={headerSearch}
      onSearchChange={setHeaderSearch}
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
        <style>{`
          @keyframes rasac-spin { to { transform: rotate(360deg); } }
          .spin-icon { animation: rasac-spin 0.7s linear infinite; transform-origin: center; }
        `}</style>
        {loadError && (
          <div className="portal-banner warning">
            <div>
              <strong>Couldn't load activity data</strong>
              <p>{loadError}</p>
            </div>
            <button className="primary-mini" type="button" onClick={loadActivity}>
              Retry
            </button>
          </div>
        )}
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
            <div className="course-metric-sub">
              Policy checks and blocked attempts
              {counts.errors > 0 && ` - ${counts.errors} error${counts.errors > 1 ? 's' : ''}`}
            </div>
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
                  value={activitySearch}
                  onChange={(e) => setActivitySearch(e.target.value)}
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
                <ChevronDown size={16} aria-hidden="true" />
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
              disabled={loading}
              onClick={loadActivity}
            >
              <RefreshCcw size={16} className={loading ? 'spin-icon' : ''} />
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
                  visibleActivity.map((log) => (
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
                        <span className={`pill ${
                          toneForLog(log) === 'success' ? 'ok'
                          : toneForLog(log) === 'warn' ? 'warn'
                          : toneForLog(log) === 'deny' ? 'deny'
                          : 'info'
                        }`}>
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
          {filteredActivity.length > 0 && (
            <div className="table-footer">
              <span style={{ color: 'var(--muted)', fontSize: 13 }}>
                Showing {((safePage - 1) * pageSize) + 1}-{Math.min(safePage * pageSize, filteredActivity.length)} of {filteredActivity.length} activity entries.
              </span>
              <div className="pagination">
                <button
                  type="button"
                  aria-label="Previous activity page"
                  disabled={safePage === 1}
                  onClick={() => setPage((current) => Math.max(1, current - 1))}
                >
                  &lt;
                </button>
                <button type="button" className="active">{safePage}</button>
                <button
                  type="button"
                  aria-label="Next activity page"
                  disabled={safePage === totalPages}
                  onClick={() => setPage((current) => Math.min(totalPages, current + 1))}
                >
                  &gt;
                </button>
              </div>
            </div>
          )}
        </section>
      </section>
    </Shell>
  );
}

import { useEffect, useState, useMemo } from 'react';
import {
  LayoutDashboard, BookOpen, Users, Shield, FileText,
  Settings, RefreshCcw, Bell, Monitor, ChevronDown, ChevronLeft, ChevronRight,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, AuthenticatedUser, AuditLog, AuditOutcome } from '../../types';
import { api } from '../../api';


type DenyLayer = 'ROLE' | 'RELATIONSHIP' | 'CONTEXT' | 'SOD' | 'ALL_LAYER_VALUE' | '—';
const LOGS_PER_PAGE = 10;

export function AuditLogsScreen({
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const sidebarItems: NavItem[] = [
    { view: 'dashboard',       label: 'Dashboard',      icon: <LayoutDashboard size={20} /> },
    { view: 'course-detail',   label: 'Courses',        icon: <BookOpen size={20} /> },
    { view: 'user-management', label: 'Users',          icon: <Users size={20} /> },
    { view: 'access-control', label: 'Access Control', icon: <Shield size={20} /> },
    { view: 'audit-logs',      label: 'Audit Logs',     icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings',icon: <Settings size={20} /> },
  ];

  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [stats, setStats] = useState<{
    outcomes: Record<string, number>;
    denyCounts: { role: number; relationship: number; context: number; sod: number };
  } | null>(null);
  const [expandedLogId, setExpandedLogId] = useState<number | null>(null);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [deepSearch, setDeepSearch] = useState('');
  const [copiedLogId, setCopiedLogId] = useState<number | null>(null);
  const [page, setPage] = useState(1);

  // Filter state
  const [search, setSearch] = useState('');
  const [outcomeFilter, setOutcomeFilter] = useState<AuditOutcome | 'ALL'>('ALL');
  const [layerFilter, setLayerFilter] = useState<DenyLayer | 'ANY'>('ANY');

  const loadAuditData = async () => {
    setLoading(true);
    try {
      const [logsRes, statsRes] = await Promise.all([
        api.auditLogs(),
        api.auditStats(),
      ]);
      setLogs(logsRes.data);
      setStats(statsRes);
      setLoadError(null);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to reach the RASAC server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    loadAuditData();
  }, []);


  const outcomePillClass = (outcome: AuditOutcome) => {
  if (outcome === 'GRANTED') return 'ok';
  if (outcome === 'ERROR') return 'warn';
  return 'deny';
};

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  // Derived metrics from real data
  const total = stats ? Object.values(stats.outcomes).reduce((a, b) => a + b, 0) : 0;
  const granted = stats?.outcomes['GRANTED'] ?? 0;
  const denials = total - granted;
  const sodConflicts = stats?.denyCounts.sod ?? 0;
  const grantedPct = total > 0 ? ((granted / total) * 100).toFixed(1) : '0.0';

  // Client-side filtering
  const filtered = useMemo(() => {
    return logs.filter((log) => {
      const rawLayer = (log.metadata?.layer as string) ?? '—';
      const layer = rawLayer === 'ALL' ? 'ALL_LAYER_VALUE' : rawLayer;

      if (search) {
        const term = search.toLowerCase();
        const matchesUser = String(log.userId ?? '').includes(term);
        const matchesResource = (log.resource ?? '').toLowerCase().includes(term);
        const matchesAction = (log.action ?? '').toLowerCase().includes(term);
        if (!matchesUser && !matchesResource && !matchesAction) return false;
      }

      if (deepSearch) {
        const term = deepSearch.toLowerCase();
        const matchesIp = (log.ipAddress ?? '').toLowerCase().includes(term);
        const matchesResourceId = (log.resourceId ?? '').toLowerCase().includes(term);
        const matchesRequestPath = (log.requestPath ?? '').toLowerCase().includes(term);
        const matchesDenyReason = (log.denyReason ?? '').toLowerCase().includes(term);
        const matchesMetadata = JSON.stringify(log.metadata ?? {}).toLowerCase().includes(term);
        if (!matchesIp && !matchesResourceId && !matchesRequestPath && !matchesDenyReason && !matchesMetadata) return false;
      }

      if (outcomeFilter !== 'ALL' && log.outcome !== outcomeFilter) return false;

      if (layerFilter !== 'ANY' && layer !== layerFilter) return false;

      return true;
    });
  }, [logs, search, deepSearch, outcomeFilter, layerFilter]);

  const pageCount = Math.max(1, Math.ceil(filtered.length / LOGS_PER_PAGE));
  const pageStart = (page - 1) * LOGS_PER_PAGE;
  const pageEnd = Math.min(pageStart + LOGS_PER_PAGE, filtered.length);
  const displayStart = filtered.length > 0 ? pageStart + 1 : 0;
  const paginatedLogs = filtered.slice(pageStart, pageEnd);

  useEffect(() => {
    setPage(1);
    setExpandedLogId(null);
  }, [search, deepSearch, outcomeFilter, layerFilter]);

  useEffect(() => {
    if (page > pageCount) {
      setPage(pageCount);
      setExpandedLogId(null);
    }
  }, [page, pageCount]);

    const handleCopyJson = (log: AuditLog) => {
    navigator.clipboard.writeText(JSON.stringify(log, null, 2))
      .then(() => {
        setCopiedLogId(log.id);
        setTimeout(() => setCopiedLogId((current) => (current === log.id ? null : current)), 1500);
      })
      .catch((error) => {
        openNotice('Unable to copy log', error instanceof Error ? error.message : 'Clipboard access was denied.');
      });
  };

  return (
    <Shell
      activeView="audit-logs"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Deep search: IP, resource ID, deny reason..."
      searchValue={deepSearch}
      onSearchChange={setDeepSearch}
      sidebarItems={sidebarItems}
      footerAction={async () => {
        try {
          const { emergencyLockoutActive } = await api.accessMatrix();
          await api.toggleEmergencyLockout(!emergencyLockoutActive);
          openNotice('Emergency lockout updated', `Emergency lockout ${emergencyLockoutActive ? 'disabled' : 'enabled'}.`);
        } catch (error) {
          console.error(error);
          openNotice('Unable to update emergency lockout', error instanceof Error ? error.message : 'Unknown error');
        }
      }}
      footerActionClassName="emergency-btn"
      footerActionLabel="Emergency Lockout"
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: me?.fullName?.toUpperCase() ?? 'ADMIN', role: me?.department ?? 'Security Principal' }}
      topIcons={
        <>
          <button className="icon-chip" type="button" aria-label="Notifications" onClick={() => openNotice('Audit logs', `Viewing ${logs.length} audit log entries.`)}><Bell size={20} /></button>
          <button className="icon-chip" type="button" aria-label="Refresh" disabled={loading} onClick={() => loadAuditData()}>
            <RefreshCcw size={20} className={loading ? 'spin-icon' : ''} />
          </button>
          <div className="student-user-chip lecturer-chip">
  <div className="student-user-copy">
    <strong>{me?.fullName?.toUpperCase() ?? 'ADMIN'}</strong>
    <span>ADMIN</span>
  </div>
  <div className="student-user-avatar">
    {me?.fullName?.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase() ?? 'AD'}
  </div>
</div>
        </>
      }
      topbarClassName="audit-main"
    >
      <section className="page-stack audit-page">
        <style>{`
          @keyframes rasac-spin { to { transform: rotate(360deg); } }
          .spin-icon { animation: rasac-spin 0.7s linear infinite; transform-origin: center; }
        `}</style>

        {loadError && (
          <div className="lockout-alert" style={{ borderColor: 'var(--danger)' }}>
            <FileText size={20} className="lockout-icon" />
            <div style={{ flex: 1 }}>
              <p className="lockout-title">Couldn't load audit data</p>
              <p className="lockout-desc">{loadError}</p>
            </div>
            <button type="button" className="primary-mini" onClick={() => loadAuditData()}>
              Retry
            </button>
          </div>
        )}
        {/* Metrics tiles — real data */}
        <div className="audit-top-metrics">
          <div className="metric-tile">
            <div className="metric-title">TOTAL REQUESTS</div>
            <div className="metric-number">{total.toLocaleString()}</div>
            <div className="tiny-bar">
              <span style={{ width: total > 0 ? '100%' : '0%' }} />
            </div>
          </div>
          <div className="metric-tile green">
            <div className="metric-title">ACCESS GRANTED</div>
            <div className="metric-number small">{grantedPct}%</div>
            <div className="metric-sub">{granted.toLocaleString()} instances</div>
          </div>
          <div className="metric-tile pink">
            <div className="metric-title">POLICY DENIALS</div>
            <div className="metric-number small">{denials.toLocaleString()}</div>
            <div className="metric-sub">
              Role: {stats?.denyCounts.role ?? 0} | Rel: {stats?.denyCounts.relationship ?? 0} | Ctx: {stats?.denyCounts.context ?? 0}
            </div>
          </div>
          <div className="metric-tile amber">
            <div className="metric-title">SOD CONFLICTS</div>
            <div className="metric-number small">{sodConflicts.toLocaleString()}</div>
            <div className="metric-sub">
              {sodConflicts > 0 ? 'Manual review required' : 'No conflicts detected'}
            </div>
          </div>
        </div>

        {/* Filter bar */}
        <div className="filter-bar panel-card">
          <div className="filter-field">
            <label>User / Resource Search</label>
            <input
              placeholder="Search Principal/UUID..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="filter-field select">
            <label>Outcome</label>
            <select
              className="select-box"
              value={outcomeFilter}
              onChange={(e) => setOutcomeFilter(e.target.value as AuditOutcome | 'ALL')}
            >
              <option value="ALL">All Outcomes</option>
              <option value="GRANTED">Granted</option>
              <option value="DENIED_ROLE">Denied: Role</option>
              <option value="DENIED_RELATIONSHIP">Denied: Relationship</option>
              <option value="DENIED_CONTEXT">Denied: Context</option>
              <option value="DENIED_SOD">Denied: SoD</option>
              <option value="ERROR">Error</option>
            </select>
          </div>
          <div className="filter-field select">
            <label>Deny Layer</label>
            <select
              className="select-box"
              value={layerFilter}
              onChange={(e) => setLayerFilter(e.target.value as DenyLayer | 'ANY')}
            >
              <option value="ANY">All Layers</option>
              <option value="ROLE">Role</option>
              <option value="RELATIONSHIP">Relationship</option>
              <option value="CONTEXT">Context</option>
              <option value="SOD">SoD</option>
              <option value="ALL_LAYER_VALUE">Layer: ALL</option>
              <option value="—">No layer (granted)</option>
            </select>
          </div>
          <button
            className="outline-mini"
            type="button"
            onClick={() => { setSearch(''); setDeepSearch(''); setOutcomeFilter('ALL'); setLayerFilter('ANY'); }}
          >
            CLEAR
          </button>
        </div>

        {/* Audit table */}
        <section className="audit-table panel-card">
          <div className="audit-table-head">
            <span>Timestamp</span>
            <span>Principal ID</span>
            <span>Resource</span>
            <span>Outcome</span>
            <span>Deny Layer</span>
            <span>Action</span>
          </div>

          {filtered.length === 0 && (
            <div className="audit-entry">
              <div className="audit-row">
                <span style={{ color: 'var(--muted)', gridColumn: '1 / -1' }}>
                  No logs match the current filters.
                </span>
              </div>
            </div>
          )}

          {paginatedLogs.map((log) => (
            <div
              className={`audit-entry ${expandedLogId === log.id ? 'open' : ''}`}
              key={log.id}
            >
              <div
                className="audit-row"
                onClick={() => setExpandedLogId(expandedLogId === log.id ? null : log.id)}
                style={{ cursor: 'pointer' }}
              >
                <span>{new Date(log.timestamp).toLocaleString()}</span>
                <span className="principal">USR-{log.userId ?? 'SYS'}</span>
                <span>{log.resource}</span>
                <span>
                  <span className={`pill ${outcomePillClass(log.outcome)}`}>
                    {log.outcome}
                  </span>
                </span>
                <span>{(log.metadata?.layer as string) ?? '—'}</span>
                <button
                  className="action-chevron"
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    setExpandedLogId(expandedLogId === log.id ? null : log.id);
                  }}
                >
                  <ChevronDown
                    size={18}
                    style={{ transform: expandedLogId === log.id ? 'rotate(180deg)' : 'none' }}
                  />
                </button>
              </div>
              {expandedLogId === log.id && (
                <div className="trace-panel">
                  <div className="trace-head">
                    <strong>{log.action?.toUpperCase() ?? 'EVENT'} TRACE — {log.resource?.toUpperCase()}</strong>
                    <button
                      className="copy-json"
                      onClick={(e) => { e.stopPropagation(); handleCopyJson(log); }}
                    >
                      <Monitor size={14} /> {copiedLogId === log.id ? 'COPIED' : 'COPY JSON'}
                    </button>
                  </div>
                  <pre>{JSON.stringify(log, null, 2)}</pre>
                </div>
              )}
            </div>
          ))}

          <div className="audit-pagination">
            <div>
              Showing {displayStart}-{pageEnd} of {filtered.length} matching log entries.
              {filtered.length !== logs.length && ` ${logs.length} total.`}
              {deepSearch.trim() && ' Deep search active.'}
            </div>
            <div className="audit-pagination-controls">
              <button
                type="button"
                className="icon-chip"
                aria-label="Previous log page"
                disabled={page === 1}
                onClick={() => {
                  setPage((current) => Math.max(1, current - 1));
                  setExpandedLogId(null);
                }}
              >
                <ChevronLeft size={18} />
              </button>
              <span>Page {page} of {pageCount}</span>
              <button
                type="button"
                className="icon-chip"
                aria-label="Next log page"
                disabled={page === pageCount}
                onClick={() => {
                  setPage((current) => Math.min(pageCount, current + 1));
                  setExpandedLogId(null);
                }}
              >
                <ChevronRight size={18} />
              </button>
            </div>
          </div>
        </section>
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

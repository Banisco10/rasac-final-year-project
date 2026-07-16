import { useEffect, useState } from 'react';
import {
  LayoutDashboard, BookOpen, Users, Shield,
  FileText, Settings, RefreshCcw, Bell, CircleAlert,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem } from '../../types';
import type { AuditLog } from '../../types';
import { api } from '../../api';
import type { PreviousLoginInfo } from '../../../../shared/types.js';

type GradeQueueItem = {
  id: number;
  studentId: number;
  studentName: string;
  courseId: number;
  courseCode: string;
  courseTitle: string;
  score: number;
  grade: string;
  submitterId: number;
  submitterName: string;
  status: string;
  sodRisk: boolean;
  submittedAt: string;
};

// Corrected DonutChart — self-contained, no outer scope reference:
function DonutChart({
  role, relationship, context, sod,
}: {
  role: number;
  relationship: number;
  context: number;
  sod: number;
}) {
  const total = role + relationship + context + sod;
  const cx = 80;
  const cy = 80;
  const r = 54;
  const strokeWidth = 18;
  const circumference = 2 * Math.PI * r;

  const segments = [
    { value: role,         color: '#6b7db3' },
    { value: relationship, color: '#45f0cf' },
    { value: context,      color: '#8a8fa8' },
    { value: sod,          color: '#f5a623' },
  ];

  let offset = 0;
  const arcs = segments.map((seg) => {
    const fraction = total > 0 ? seg.value / total : 0;
    const dash = fraction * circumference;
    const gap  = circumference - dash;
    const rot  = -90 + (offset / (total || 1)) * 360;
    offset += seg.value;
    return { ...seg, dash, gap, rot, fraction };
  });

  return (
    <div className="donut-wrap">
      <svg viewBox="0 0 160 160" width="160" height="160">
        {/* Background ring */}
        <circle
          cx={cx} cy={cy} r={r}
          fill="none"
          stroke="var(--border)"
          strokeWidth={strokeWidth}
        />
        {total > 0 && arcs.map((arc, i) => (
          arc.fraction > 0 && (
            <circle
              key={i}
              cx={cx} cy={cy} r={r}
              fill="none"
              stroke={arc.color}
              strokeWidth={strokeWidth}
              strokeDasharray={`${arc.dash} ${arc.gap}`}
              strokeDashoffset={0}
              transform={`rotate(${arc.rot} ${cx} ${cy})`}
              style={{
                transition: 'stroke-dasharray 0.9s ease, transform 0.4s ease'
              }}
            />
          )
        ))}
        <text x={cx} y={cy - 8} textAnchor="middle" fontSize="22" fontWeight="700" fill="var(--text)">
          {total}
        </text>
        <text x={cx} y={cy + 10} textAnchor="middle" fontSize="9" fill="var(--muted)" letterSpacing="1">
          {total === 0 ? 'NO DENIALS' : 'DENIALS'}
        </text>
        <text x={cx} y={cy + 24} textAnchor="middle" fontSize="8" fill="var(--muted)" letterSpacing="0.5">
          TODAY
        </text>
      </svg>
    </div>
  );
}

export function DashboardHomeScreen({
  previousLogin,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  previousLogin?: PreviousLoginInfo | null;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const [stats, setStats] = useState<any>(null);
  const [liveEvents, setLiveEvents] = useState<(AuditLog & { bucket: string })[]>([]);
  const [queue, setQueue] = useState<GradeQueueItem[]>([]);
  const [decisionItem, setDecisionItem] = useState<GradeQueueItem | null>(null);
  const [lockoutOpen, setLockoutOpen] = useState(false);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [welcomeBannerOpen, setWelcomeBannerOpen] = useState(Boolean(previousLogin?.lastLogin));
  const [searchQuery, setSearchQuery] = useState('');

  const filteredEvents = liveEvents.filter((event) => {
    const text = searchQuery.toLowerCase();
    return (
      String(event.userId || '').toLowerCase().includes(text) ||
      String(event.action || '').toLowerCase().includes(text) ||
      String(event.resource || '').toLowerCase().includes(text) ||
      String(event.denyReason || '').toLowerCase().includes(text) ||
      String(event.metadata?.message || '').toLowerCase().includes(text)
    );
  });

  const filteredQueue = queue.filter((item) => {
    const text = searchQuery.toLowerCase();
    return (
      String(item.studentName || '').toLowerCase().includes(text) ||
      String(item.courseCode || '').toLowerCase().includes(text) ||
      String(item.courseTitle || '').toLowerCase().includes(text) ||
      String(item.status || '').toLowerCase().includes(text)
    );
  });


    const formatPreviousLogin = (info: PreviousLoginInfo) => {
    const when = info.lastLogin
      ? new Date(info.lastLogin).toLocaleString()
      : 'This is your first recorded login';
    const where = info.ipAddress ? ` from ${info.ipAddress}` : '';
    return info.lastLogin ? `${when}${where}` : when;
  };

  const loadDashboard = async () => {
    const [statsResponse, eventsResponse, queueResponse] = await Promise.all([
      api.adminStats(),
      api.securityEvents(),
      api.gradeApprovalQueue(),
    ]);

    setStats(statsResponse);
    const flat = [
      ...eventsResponse.ROLE.map((e) => ({ ...e, bucket: 'ROLE' })),
      ...eventsResponse.RELATIONSHIP.map((e) => ({ ...e, bucket: 'REL' })),
      ...eventsResponse.CONTEXT.map((e) => ({ ...e, bucket: 'CONT' })),
      ...eventsResponse.SOD.map((e) => ({ ...e, bucket: 'SOD' })),
    ]
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 5);
    setLiveEvents(flat);
    setQueue(queueResponse.data);
  };

  useEffect(() => {
    loadDashboard().catch(console.error);
  }, []);

  

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const handleQueueAction = async (item: GradeQueueItem, approve: boolean) => {
    try {
      if (approve) {
        await api.approveGrade(item.id);
      } else {
        await api.rejectGrade(item.id);
      }
      setDecisionItem(null);
      await loadDashboard();
    } catch (error) {
      console.error(error);
      openNotice('Unable to complete the grade decision', error instanceof Error ? error.message : 'Unknown error');
    }
  };

  const sidebarItems: NavItem[] = [
    { view: 'dashboard',       label: 'Dashboard',      icon: <LayoutDashboard size={20} /> },
    { view: 'course-detail',   label: 'Courses',         icon: <BookOpen size={20} /> },
    { view: 'user-management', label: 'Users',           icon: <Users size={20} /> },
    { view: 'role-management', label: 'Access Control',  icon: <Shield size={20} /> },
    { view: 'audit-logs',      label: 'Audit Logs',      icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const denialBars = [
    { label: `ROLE (${stats?.denialsToday.role || 0})`,         width: '45%', tone: 'role' },
    { label: `REL (${stats?.denialsToday.relationship || 0})`,  width: '25%', tone: 'rel' },
    { label: `CONT (${stats?.denialsToday.context || 0})`,      width: '20%', tone: 'cont' },
    { label: `SOD (${stats?.denialsToday.sod || 0})`,           width: '10%', tone: 'sod' },
  ];

  const comparisonRows = [
    ['Decision Source', 'Static Role Membership',    'Dynamic Relationship + Context'],
    ['Hierarchy',       'Rigid Parent-Child',         'Fluid Graph-Based Relationships'],
    ['SoD Enforcement', 'Manual Role Exclusion',      'Automated Cross-Entity Conflict Check'],
    ['Scale Path',      'Role Explosion (O^n)',        'Linear Relationship Scaling'],
  ];

  return (
    <Shell
      activeView="dashboard"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search security logs..."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
      sidebarItems={sidebarItems}
      footerAction={() => setLockoutOpen(true)}
      footerActionClassName="emergency-btn"
      footerActionLabel={stats?.emergencyLockoutActive ? 'Disable Lockout' : 'Emergency Lockout'}
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: 'ADMIN_01', role: 'Security Principal' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            type="button"
            aria-label="Notifications"
            onClick={() => openNotice('Dashboard summary', `You have ${stats?.denialsToday.total ?? 0} policy denials and ${queue.length} queued grade decisions.`)}
          >
            <Bell size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Refresh" onClick={() => loadDashboard().catch(console.error)}>
            <RefreshCcw size={20} />
          </button>
          <button
            className="profile-chip"
            type="button"
            onClick={() => openNotice('Administrator profile', 'ADMIN_01 | Security Principal | RASAC framework administrator')}
          >
            <img alt="profile" src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80" />
          </button>
        </>
      }
      topbarClassName="dashboard-main"
    >
      <section className="page-stack dashboard-page">
        {welcomeBannerOpen && previousLogin && (
          <div className="lockout-alert" style={{ marginBottom: '16px' }}>
            <Bell size={20} className="lockout-icon" />
            <div style={{ flex: 1 }}>
              <p className="lockout-title">Welcome back, Administrator</p>
              <p className="lockout-desc">
                Last login: {previousLogin.lastLogin ? new Date(previousLogin.lastLogin).toLocaleString() : 'This is your first recorded login'}
              </p>
              {previousLogin.ipAddress && (
                <p className="lockout-desc">Station IP: {previousLogin.ipAddress}</p>
              )}
            </div>
            <button
              type="button"
              className="icon-chip"
              aria-label="Dismiss"
              onClick={() => setWelcomeBannerOpen(false)}
            >
              ×
            </button>
          </div>
        )}
        <div className="dashboard-intro">
          <div>
            <div className="hero-kicker">Security Command</div>
            <h1>Relationship-Based Access Control Overview</h1>
            <p>Operational overview for the current academic period and authorization queue.</p>
          </div>
        </div>

        <section className="dashboard-grid">
          <article className="hero-panel">
            <div className="hero-accent" />
              <div className="hero-copy">
              <div className="eyebrow">CURRENT STATUS</div>
              <h2>{stats?.activePeriod?.name?.toUpperCase() ?? 'NO ACTIVE PERIOD'}</h2>
              <button
                className="status-pill open"
                type="button"
                onClick={() => openNotice(
                  'Academic period',
                  stats?.activePeriod
                    ? `${stats.activePeriod.name}\n${new Date(stats.activePeriod.startDate).toLocaleDateString()} - ${new Date(stats.activePeriod.endDate).toLocaleDateString()}`
                    : 'No active academic period is configured.'
                )}
              >
                {stats?.activePeriod ? 'OPEN' : 'CLOSED'}
              </button>
            </div>
            <div className="hero-period">
              <div className="eyebrow">PERIOD ENDS</div>
              <div className="countdown">
                {stats?.activePeriod
                  ? new Date(stats.activePeriod.endDate).toLocaleDateString()
                  : '—'}
              </div>
            </div>
            <button className="primary-mini" type="button" onClick={() => onNavigate('system-settings')}>
              MANAGE PERIOD
            </button>
          </article>

          <div className="stats-grid">
            <div className="metric-card">
              <div className="metric-label">TOTAL USERS</div>
              <div className="metric-value">{stats?.userCounts.total ?? '...'}</div>
              <div className="metric-detail">
                Admin: {stats?.userCounts.administrators ?? '—'} | Lect: {stats?.userCounts.lecturers ?? '—'}
              </div>
            </div>
            <div className="metric-card">
              <div className="metric-label">ACTIVE SESSIONS</div>
              <div className="metric-value">{stats?.activeSessions ?? '0'}</div>
              <div className="metric-detail">Live Identity Tokens</div>
            </div>
            <section className="denial-card panel-card">
              <div className="panel-top">
                <h3>DENIALS TODAY</h3>
                <strong>{stats?.denialsToday.total || 0}</strong>
              </div>
              <div className="bar-row">
                {denialBars.map((bar) => (
                  <div key={bar.label} className={`bar-group ${bar.tone}`} style={{ width: bar.width }}>
                    <div className="bar-fill" />
                  </div>
                ))}
              </div>
              <div className="bar-labels">
                {denialBars.map((bar) => (
                  <span key={bar.label}>{bar.label}</span>
                ))}
              </div>
            </section>
          </div>

          <section className="ring-card panel-card">
              <div className="panel-heading">
                <h3>DENIAL DISTRIBUTION</h3>
                <CircleAlert size={18} />
              </div>
              <DonutChart
                role={stats?.denialsToday.role ?? 0}
                relationship={stats?.denialsToday.relationship ?? 0}
                context={stats?.denialsToday.context ?? 0}
                sod={stats?.denialsToday.sod ?? 0}
              />
              <div className="legend-grid">
                <div><span className="legend-dot slate" />ROLE ({stats?.denialsToday.role ?? 0})</div>
                <div><span className="legend-dot aqua" />RELATIONSHIP ({stats?.denialsToday.relationship ?? 0})</div>
                <div><span className="legend-dot gray" />CONTEXT ({stats?.denialsToday.context ?? 0})</div>
                <div><span className="legend-dot amber" />SOD ({stats?.denialsToday.sod ?? 0})</div>
              </div>
            </section>

          <section className="events-card panel-card">
            <div className="panel-heading">
              <h3>REAL-TIME EVENTS</h3>
              <span className="live-chip"><span />LIVE MONITOR</span>
            </div>
            <div className="events-list">
              {filteredEvents.length === 0 ? (
                <div className="event-row">
                  <div className="event-body">No denial events recorded.</div>
                </div>
              ) : (
                filteredEvents.map((log) => {
                  const badges = [log.bucket, log.denyReason].filter(Boolean) as string[];
                  const body = (log.metadata?.message as string)
                    ?? `Resource: ${log.resource}`;
                  return (
                    <div key={log.id} className="event-row">
                      <div className="event-head">
                        <div className="event-title">
                          USR_{log.userId ?? 'SYS'} → {log.action.toUpperCase()}
                        </div>
                        <div className="status-pill denied">DENIED</div>
                      </div>
                      <div className="badge-row">
                        {badges.map((badge) => (
                          <span key={badge} className="tiny-badge">{badge}</span>
                        ))}
                      </div>
                      <div className="event-body">
                        {new Date(log.timestamp).toLocaleTimeString()} | {body}
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </section>

          <section className="queue-card panel-card">
            <div className="panel-heading">
              <h3>GRADE APPROVAL QUEUE</h3>
            </div>
            <div className="queue-head">
              <span>SUBJECT</span>
              <span>STATUS</span>
              <span>ACTION</span>
            </div>
            {filteredQueue.length === 0 ? (
              <div className="queue-row">
                <div className="queue-sub">No pending grades.</div>
              </div>
            ) : (
              filteredQueue.slice(0, 5).map((item) => (
                <div key={item.id} className={`queue-row ${item.status === 'REJECTED' ? 'queue-row--rejected' : ''}`}>
                  <div>
                    <div className="queue-title">{item.courseCode}</div>
                    <div className="queue-sub">{item.studentName}</div>
                    {item.status === 'REJECTED' && (
                      <div className="queue-rejected-tag">REJECTED — awaiting resubmission</div>
                    )}
                  </div>
                  <div className={`queue-status ${item.sodRisk ? 'risk' : item.status === 'REJECTED' ? 'rejected' : 'pending'}`}>
                    {item.sodRisk ? 'SoD Risk' : item.status === 'REJECTED' ? 'REJECTED' : 'PENDING'}
                  </div>
                  {item.status !== 'REJECTED' && (
                    <button
                      className={`queue-action ${item.sodRisk ? 'review' : 'approve'}`}
                      type="button"
                      onClick={() => setDecisionItem(item)}
                    >
                      {item.sodRisk ? 'REVIEW' : 'APPROVE'}
                    </button>
                  )}
                  {item.status === 'REJECTED' && (
                    <span className="queue-action-label">Lecturer notified</span>
                  )}
                </div>
              ))
            )}
            {filteredQueue.length > 5 && (
              <button className="view-all" type="button" onClick={() => onNavigate('audit-logs')}>
                VIEW ALL ({filteredQueue.length})
              </button>
            )}
          </section>

          <section className="comparison-card panel-card">
            <div className="panel-heading">
              <h3>ACCESS ARCHITECTURE COMPARISON</h3>
            </div>
            <div className="comparison-table">
              <div className="comparison-head">
                <span>FEATURE</span>
                <span>TRADITIONAL RBAC</span>
                <span className="highlight">RASAC (IMPLEMENTED)</span>
              </div>
              {comparisonRows.map(([feature, legacy, rasac]) => (
                <div key={feature} className="comparison-row">
                  <strong>{feature}</strong>
                  <span>{legacy}</span>
                  <span>{rasac}</span>
                </div>
              ))}
            </div>
          </section>
        </section>
      </section>

      <Modal
        open={Boolean(decisionItem)}
        title={decisionItem?.sodRisk ? 'Review grade decision' : 'Approve grade'}
        description={decisionItem ? `${decisionItem.courseCode} | ${decisionItem.studentName}` : ''}
        onClose={() => setDecisionItem(null)}
        footer={decisionItem ? (
          <>
            <button type="button" className="outlined-btn" onClick={() => handleQueueAction(decisionItem, false).catch(console.error)}>
              Reject
            </button>
            <button type="button" className="primary-mini" onClick={() => handleQueueAction(decisionItem, true).catch(console.error)}>
              {decisionItem.sodRisk ? 'Approve Anyway' : 'Approve'}
            </button>
          </>
        ) : null}
      >
        <div className="modal-info-grid">
          <div><strong>Student</strong><span>{decisionItem?.studentName}</span></div>
          <div><strong>Course</strong><span>{decisionItem?.courseCode}</span></div>
          <div><strong>Status</strong><span>{decisionItem?.status}</span></div>
          <div><strong>SoD Risk</strong><span>{decisionItem?.sodRisk ? 'Yes' : 'No'}</span></div>
        </div>
      </Modal>

      <Modal
        open={lockoutOpen}
        title={stats?.emergencyLockoutActive ? 'Disable emergency lockout' : 'Enable emergency lockout'}
        description={stats?.emergencyLockoutActive ? 'Restore standard access for all active sessions.' : 'Lock out all active sessions until the policy is cleared.'}
        onClose={() => setLockoutOpen(false)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setLockoutOpen(false)}>Cancel</button>
            <button
              type="button"
              className="primary-mini"
              onClick={async () => {
                try {
                  await api.toggleEmergencyLockout(!stats?.emergencyLockoutActive);
                  setLockoutOpen(false);
                  await loadDashboard();
                } catch (error) {
                  console.error(error);
                  openNotice('Emergency lockout update failed', error instanceof Error ? error.message : 'Unknown error');
                }
              }}
            >
              {stats?.emergencyLockoutActive ? 'Disable' : 'Enable'}
            </button>
          </>
        )}
      >
        <p style={{ color: 'var(--text-muted)' }}>
          This action affects the entire platform immediately.
        </p>
      </Modal>

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

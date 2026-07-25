import { useEffect, useState } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  ShieldCheck,
  FileText,
  Settings,
  RefreshCcw,
  Bell,
  Monitor,
  Check,
  Users,
  UserRoundCheck,
  Shield,
  Plus,
  AlertTriangle,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, PolicyConfig, AuthenticatedUser } from '../../types';
import { api } from '../../api';

type RoleKey = keyof PolicyConfig['matrix'];
type ActionKey = 'read' | 'write' | 'delete' | 'approve';

export function AccessControlScreen({
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const sidebarItems: NavItem[] = [
    { view: 'dashboard', label: 'Dashboard', icon: <LayoutDashboard size={20} /> },
    { view: 'course-detail', label: 'Courses', icon: <BookOpen size={20} /> },
    { view: 'user-management', label: 'Users', icon: <Users size={20} /> },
    { view: 'access-control', label: 'Access Control', icon: <ShieldCheck size={20} /> },
    { view: 'audit-logs', label: 'Audit Logs', icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [matrix, setMatrix] = useState<{
    roles: Array<{ id: number; name: string; description?: string | null }>;
    policyConfig: PolicyConfig | null;
    emergencyLockoutActive: boolean;
  }>({ roles: [], policyConfig: null, emergencyLockoutActive: false });
  const [draftPolicy, setDraftPolicy] = useState<PolicyConfig | null>(null);
  const [dirty, setDirty] = useState(false);
  const [saving, setSaving] = useState(false);
  const [ipModalOpen, setIpModalOpen] = useState(false);
  const [ipRange, setIpRange] = useState('');
  const [confirmLockoutOpen, setConfirmLockoutOpen] = useState(false);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [pendingToggle, setPendingToggle] = useState<{ role: RoleKey; action: ActionKey } | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [confirmDiscardOpen, setConfirmDiscardOpen] = useState(false);
  const [ipError, setIpError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const loadMatrix = async () => {
    try {
      const response = await api.accessMatrix();
      setMatrix(response);
      setDraftPolicy(response.policyConfig);
      setDirty(false);
      setLoadError(null);
    } catch (error) {
      setLoadError(error instanceof Error ? error.message : 'Unable to reach the RASAC server.');
    }
  };

  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    loadMatrix();
  }, []);

  const displayName = me?.fullName ?? 'Administrator';

  const config = draftPolicy ?? matrix.policyConfig;

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const applyTogglePermission = (role: RoleKey, action: ActionKey) => {
    setDraftPolicy((current) => {
      const base = current ?? matrix.policyConfig;
      if (!base) return current;
      const currentRoleConfig = base.matrix[role];
      return {
        ...base,
        matrix: {
          ...base.matrix,
          [role]: {
            ...currentRoleConfig,
            [action]: !currentRoleConfig[action],
          },
        },
      };
    });
    setDirty(true);
  };

  const togglePermission = (role: RoleKey, action: ActionKey) => {
    const base = config;
    const isOwnRole = me?.role === role;
    const isCurrentlyGranted = base?.matrix?.[role]?.[action] ?? false;

    // Only intercept when the admin is about to REMOVE a permission from their OWN role —
    // that's the specific action that risks locking every admin out of this screen.
    if (isOwnRole && isCurrentlyGranted) {
      setPendingToggle({ role, action });
      return;
    }
    applyTogglePermission(role, action);
  };

  const roleRows = matrix.roles.map((role) => {
    const roleKey = role.name as RoleKey;
    const roleConfig = config?.matrix?.[roleKey];
    return {
      role: role.name,
      desc: role.description ?? 'System role',
      actions: (['read', 'write', 'delete', 'approve'] as ActionKey[]).map((action) => ({
        action,
        checked: roleConfig?.[action] ?? false,
      })),
    };
  });

  const handleSavePermissions = async () => {
    if (!draftPolicy) return;
    setSaving(true);
    try {
      await api.updateAccessMatrix(draftPolicy);
      await loadMatrix();
      openNotice('Access control policy saved', 'The updated policy was deployed successfully.');
    } catch (error) {
      console.error(error);
      openNotice('Unable to save permissions', error instanceof Error ? error.message : 'Unknown error');
    } finally {
      setSaving(false);
    }
  };

  const handleDiscardChanges = async () => {
    await loadMatrix();
    if (!loadError) {
      openNotice('Draft changes discarded', 'Access control edits were reset to the latest saved policy.');
    }
  };

  const handleAddIpRange = () => {
    const trimmed = ipRange.trim();

    if (!trimmed) {
      setIpError('Enter an IP range.');
      return;
    }
    if (!isValidIpRange(trimmed)) {
      setIpError('Enter a valid IPv4 address or CIDR range, e.g. 10.0.0.0/24.');
      return;
    }
    if ((config?.environmental.ipRanges ?? []).includes(trimmed)) {
      setIpError('This range is already in the list.');
      return;
    }

    setDraftPolicy((current) => {
      const base = current ?? matrix.policyConfig;
      if (!base) return current;
      return {
        ...base,
        environmental: {
          ...base.environmental,
          ipRanges: [...base.environmental.ipRanges, trimmed],
        },
      };
    });
    setDirty(true);
    setIpRange('');
    setIpError(null);
    setIpModalOpen(false);
    openNotice('IP range added', 'The new network range has been added to the draft policy. Remember to save.');
  };

  const isValidIpRange = (value: string) => {
  // Matches an IPv4 address, optionally with a /0–32 CIDR suffix
  const pattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})(\/(\d{1,2}))?$/;
  const match = value.match(pattern);
  if (!match) return false;

  const octets = [match[1], match[2], match[3], match[4]].map(Number);
  if (octets.some((o) => o < 0 || o > 255)) return false;

  if (match[6] !== undefined) {
    const prefix = Number(match[6]);
    if (prefix < 0 || prefix > 32) return false;
  }

  return true;
};

  const removeIpRange = (range: string) => {
    setDraftPolicy((current) => {
      const base = current ?? matrix.policyConfig;
      if (!base) return current;
      return {
        ...base,
        environmental: {
          ...base.environmental,
          ipRanges: base.environmental.ipRanges.filter((r) => r !== range),
        },
      };
    });
    setDirty(true);
  };

  const toggleTimeWindowBlock = () => {
    setDraftPolicy((current) => {
      const base = current ?? matrix.policyConfig;
      if (!base) return current;
      return {
        ...base,
        environmental: {
          ...base.environmental,
          timeWindow: {
            ...base.environmental.timeWindow,
            blockOutside: !base.environmental.timeWindow.blockOutside,
          },
        },
      };
    });
    setDirty(true);
  };

  const matchesSearch = (text: string) =>
  !searchQuery.trim() || text.toLowerCase().includes(searchQuery.toLowerCase().trim());

  const handleEmergencyLockout = async () => {
    const enable = !matrix.emergencyLockoutActive;
    try {
      await api.toggleEmergencyLockout(enable);
      await loadMatrix();
      setConfirmLockoutOpen(false);
      openNotice(
        'Emergency lockout updated',
        enable ? 'Emergency lockout has been enabled.' : 'Emergency lockout has been disabled.'
      );
    } catch (error) {
      console.error(error);
      setConfirmLockoutOpen(false);
      openNotice('Emergency lockout update failed', error instanceof Error ? error.message : 'Unknown error');
    }
  };

  // Time window progress bar — compute percentage of day elapsed within window
  const timeWindowPercent = (() => {
    if (!config?.environmental.timeWindow) return 0;
    const [startH, startM] = config.environmental.timeWindow.start.split(':').map(Number);
    const [endH, endM] = config.environmental.timeWindow.end.split(':').map(Number);
    const now = new Date();
    const nowMins = now.getHours() * 60 + now.getMinutes();
    const startMins = startH * 60 + (startM || 0);
    const endMins = endH * 60 + (endM || 0);

    // Overnight window (e.g. 22:00–06:00): span wraps past midnight.
    const overnight = endMins <= startMins;
    const span = overnight ? (endMins + 1440) - startMins : endMins - startMins;
    if (span <= 0) return 0;

    // Normalize "now" onto the same wrapped timeline as the window.
    const nowNormalized = overnight && nowMins < startMins ? nowMins + 1440 : nowMins;
    const elapsed = Math.min(Math.max(nowNormalized - startMins, 0), span);
    return Math.round((elapsed / span) * 100);
  })();
  
  return (
    <Shell
      activeView="access-control"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search roles or constraints..."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
      sidebarItems={sidebarItems}
      footerAction={() => setConfirmLockoutOpen(true)}
      footerActionClassName="emergency-btn"
      footerActionLabel={matrix.emergencyLockoutActive ? 'Disable Lockout' : 'Emergency Lockout'}
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Security Principal' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            type="button"
            aria-label="Notifications"
            onClick={() => openNotice(
              'Emergency lockout status',
              `Emergency lockout is ${matrix.emergencyLockoutActive ? 'active' : 'inactive'}.`
            )}
          >
            <Bell size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Console" onClick={() => onNavigate('audit-logs')}>
            <Monitor size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Settings" onClick={() => onNavigate('system-settings')}>
            <Settings size={20} />
          </button>
          <button
            className="profile-chip small"
            type="button"
            onClick={() => openNotice('Access control console', `${displayName} | Security Principal`)}
          >
            <div className="student-user-avatar">
              {displayName.split(' ').map((n) => n[0]).join('').slice(0, 2).toUpperCase()}
            </div>
          </button>
        </>
      }
      topbarClassName="role-main"
    >
      <section className="page-stack access-page">
        <div className="role-hero">
          <div className="breadcrumbs">Administration &gt; <span>Access Control</span></div>
          <div className="role-header-row">
            <div>
              <h1>Global Permission Matrix</h1>
              <p>
                Manage role-based permissions across the RASAC framework. Toggle a cell to grant or
                revoke an action for a role — changes apply system-wide once saved.
              </p>
            </div>
            <div className="role-actions">
              {dirty && <span className="unsaved-indicator">Unsaved changes</span>}
              <button
                className="outlined-btn"
                type="button"
                disabled={!dirty}
                onClick={() => setConfirmDiscardOpen(true)}
              >
                Discard Changes
              </button>
              <button
                className="primary-mini"
                type="button"
                disabled={saving || !dirty}
                onClick={() => handleSavePermissions().catch(console.error)}
              >
                {saving ? 'Saving...' : 'Save Permissions'}
              </button>
            </div>
          </div>
        </div>

        {loadError && (
          <div className="lockout-alert" style={{ borderColor: 'var(--danger)' }}>
            <AlertTriangle size={20} className="lockout-icon" />
            <div style={{ flex: 1 }}>
              <p className="lockout-title">Couldn't load the access control policy</p>
              <p className="lockout-desc">{loadError}</p>
            </div>
            <button type="button" className="primary-mini" onClick={() => loadMatrix()}>
              Retry
            </button>
          </div>
        )}


        <div className="access-grid">
          <section className="panel-card matrix-card">
            <div className="panel-heading matrix-heading">
              <div className="matrix-heading-left">
                <div className="section-tag outline">ROLE LAYER</div>
                <h3>GLOBAL PERMISSION MATRIX</h3>
              </div>
              <div className="policy-id">POL-AC-001</div>
            </div>
            <div className="matrix-table">
              <div className="matrix-head">
                <span>System Role</span>
                <span>Read</span>
                <span>Write</span>
                <span>Delete</span>
                <span>Approve</span>
              </div>
              {roleRows.map(({ role, desc, actions }) => (
                <div
                  className="matrix-row"
                  key={role}
                  style={searchQuery.trim() && !matchesSearch(role) && !matchesSearch(desc) ? { opacity: 0.35 } : undefined}
                >
                  <div>
                    <strong>{role}</strong>
                    <span>{desc}</span>
                  </div>
                  {actions.map(({ action, checked }) => (
                    <button
                      key={`${role}-${action}`}
                      type="button"
                      className={`matrix-check matrix-check-btn ${checked ? 'checked' : 'unchecked'}`}
                      onClick={() => togglePermission(role as RoleKey, action)}
                      aria-pressed={checked}
                      aria-label={`${role} ${action} permission, currently ${checked ? 'granted' : 'denied'}`}
                    >
                      {checked ? <Check size={13} strokeWidth={4} /> : ''}
                    </button>
                  ))}
                </div>
              ))}
            </div>
          </section>

          <section className="panel-card associate-card">
            <div className="panel-heading">
              <div className="matrix-heading-left">
                <div className="section-tag outline">RELATIONSHIP LOGIC</div>
                <h3>ACADEMIC ASSOCIATIONS</h3>
              </div>
            </div>
            <div className="association-block" style={searchQuery.trim() && !matchesSearch('Enrolled in Course') ? { opacity: 0.35 } : undefined}>
              <div className="association-icon"><Users size={24} /></div>
              <div className="association-main">
                <div className="association-head">
                  <strong>Enrolled in Course</strong>
                  <span>{config?.associations.enrolledInCourse.isActive ? 'ACTIVE' : 'OFF'}</span>
                </div>
                <div className="association-fields">
                  <div className="mini-field">
                    <label>Strength Threshold</label>
                    <div className="mini-input">{config?.associations.enrolledInCourse.strengthThreshold ?? '—'}</div>
                  </div>
                  <div className="mini-field">
                    <label>Timeout (Mins)</label>
                    <div className="mini-input">{config?.associations.enrolledInCourse.timeoutMins ?? '—'}</div>
                  </div>
                </div>
              </div>
            </div>
            <div className="association-block" style={searchQuery.trim() && !matchesSearch('Assigned Lecturer') ? { opacity: 0.35 } : undefined}>
              <div className="association-icon"><UserRoundCheck size={24} /></div>
              <div className="association-main">
                <div className="association-head">
                  <strong>Assigned Lecturer</strong>
                  <span>{config?.associations.assignedLecturer.isActive ? 'ACTIVE' : 'OFF'}</span>
                </div>
                <div className="association-fields">
                  <div className="mini-field">
                    <label>Verification Depth</label>
                    <div className="mini-input">{config?.associations.assignedLecturer.verificationDepth ?? '—'}</div>
                  </div>
                  <div className="mini-field">
                    <label>Re-auth Cycle</label>
                    <div className="mini-input">{config?.associations.assignedLecturer.reauthCycle ?? '—'}</div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="panel-card constraints-card">
            <div className="panel-heading">
              <div className="matrix-heading-left">
                <div className="section-tag dotted">CONTEXTUAL</div>
                <h3>ENVIRONMENTAL CONSTRAINTS</h3>
              </div>
            </div>
            <div className="constraints-stack">
              <div className="constraint-box" style={searchQuery.trim() && !matchesSearch('IP Range Restrictions') ? { opacity: 0.35 } : undefined}>
                <div className="constraint-head">
                  <strong>IP Range Restrictions</strong>
                  <Shield size={16} />
                </div>
                <div className="chip-row">
                  {(config?.environmental.ipRanges ?? []).map((range) => (
                    <span className="chip chip-removable" key={range}>
                      {range}
                      <button type="button" aria-label={`Remove ${range}`} onClick={() => removeIpRange(range)}>
                        ×
                      </button>
                    </span>
                  ))}
                  <button className="chip add-chip" type="button" aria-label="Add IP range" onClick={() => { setIpError(null); setIpModalOpen(true); }}>
                    <Plus size={14} />
                  </button>
                </div>
                <p>Geo-fencing active for Registrar data access.</p>
              </div>

              <div className="constraint-box" style={searchQuery.trim() && !matchesSearch('Time-of-Day Windows') ? { opacity: 0.35 } : undefined}>
                <div className="constraint-head">
                  <strong>Time-of-Day Windows</strong>
                </div>
                <div className="constraint-time">
                  <div className="constraint-track">
                    <span style={{ width: `${timeWindowPercent}%` }} />
                  </div>
                  <div className="constraint-hours">
                    {config?.environmental.timeWindow.start ?? '08:00'} - {config?.environmental.timeWindow.end ?? '18:00'}
                  </div>
                </div>
                <div className="constraint-foot">
                  <p>{config?.environmental.timeWindow.blockOutside ? 'Access blocked outside academic hours.' : 'Outside-hour access allowed.'}</p>
                  <button
                    type="button"
                    className={`constraint-check constraint-check-btn ${config?.environmental.timeWindow.blockOutside ? 'on' : 'off'}`}
                    onClick={toggleTimeWindowBlock}
                    aria-pressed={config?.environmental.timeWindow.blockOutside ?? false}
                    aria-label="Toggle time window enforcement"
                  >
                    {config?.environmental.timeWindow.blockOutside ? <Check size={12} strokeWidth={4} /> : ''}
                  </button>
                </div>
              </div>

              <div className="constraint-box alert" style={searchQuery.trim() && !matchesSearch('Grading Period Constraints') ? { opacity: 0.35 } : undefined}>
                <div className="constraint-head">
                  <strong>Grading Period Constraints</strong>
                  <AlertTriangle size={18} />
                </div>
                <p>
                  Write access to Gradebook is strictly restricted unless current system date is within
                  [{config?.environmental.gradingPeriod.requiredPeriod ?? 'FINAL_EXAM_PERIOD'}].
                </p>
                <div className="constraint-meter">
                  <span style={{ width: `${Math.min(100, Math.max(0, ((config?.environmental.gradingPeriod.daysLeft ?? 14) / 30) * 100))}%` }} />
                  <strong>{config?.environmental.gradingPeriod.daysLeft ?? 14} DAYS LEFT</strong>
                </div>
              </div>
            </div>
          </section>
        </div>
      </section>

      <Modal
        open={ipModalOpen}
        title="Add allowed IP range"
        description="Add a network range to the draft policy before saving."
        onClose={() => { setIpModalOpen(false); setIpError(null); }}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => { setIpModalOpen(false); setIpError(null); }}>Cancel</button>
            <button type="button" className="primary-mini" onClick={handleAddIpRange}>Add Range</button>
          </>
        )}
      >
        <label className="modal-field">
          <span>Allowed IP range</span>
          <input value={ipRange} onChange={(e) => setIpRange(e.target.value)} placeholder="10.0.0.0/24" />
          {ipError && <small style={{ color: 'var(--danger)' }}>{ipError}</small>}
        </label>
      </Modal>

      <Modal
        open={Boolean(pendingToggle)}
        title="Remove your own access?"
        description={pendingToggle ? `${pendingToggle.role} — ${pendingToggle.action.toUpperCase()}` : ''}
        onClose={() => setPendingToggle(null)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setPendingToggle(null)}>Cancel</button>
            <button
              type="button"
              className="primary-mini"
              onClick={() => {
                if (pendingToggle) applyTogglePermission(pendingToggle.role, pendingToggle.action);
                setPendingToggle(null);
              }}
            >
              Remove Anyway
            </button>
          </>
        )}
      >
        <p style={{ color: 'var(--text-muted)' }}>
          This permission belongs to your own role. Removing it — once saved — could immediately
          restrict your own access to this system, including this permission matrix itself.
          If no other administrator retains this permission, it may be difficult to reverse.
        </p>
      </Modal>

      <Modal
        open={confirmLockoutOpen}
        title={matrix.emergencyLockoutActive ? 'Disable emergency lockout' : 'Enable emergency lockout'}
        description={matrix.emergencyLockoutActive ? 'Restore standard access for all active sessions.' : 'Lock out all active sessions until the policy is cleared.'}
        onClose={() => setConfirmLockoutOpen(false)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setConfirmLockoutOpen(false)}>Cancel</button>
            <button type="button" className="primary-mini" onClick={() => handleEmergencyLockout().catch(console.error)}>
              {matrix.emergencyLockoutActive ? 'Disable' : 'Enable'}
            </button>
          </>
        )}
      >
        <p style={{ color: 'var(--text-muted)' }}>
          This change will affect access control globally.
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

      <Modal
        open={confirmDiscardOpen}
        title="Discard unsaved changes?"
        description="This will reset the permission matrix and constraints back to the last saved policy."
        onClose={() => setConfirmDiscardOpen(false)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setConfirmDiscardOpen(false)}>Cancel</button>
            <button
              type="button"
              className="primary-mini"
              onClick={() => {
                setConfirmDiscardOpen(false);
                handleDiscardChanges();
              }}
            >
              Discard Changes
            </button>
          </>
        )}
      >
        <p style={{ color: 'var(--text-muted)' }}>
          All unsaved edits — permission toggles, IP ranges, and time-window settings — will be lost.
        </p>
      </Modal>
    </Shell>
  );
}

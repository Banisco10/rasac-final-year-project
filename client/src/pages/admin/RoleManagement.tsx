import { useEffect, useMemo, useState } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  Users,
  ShieldCheck,
  FileText,
  Settings,
  RefreshCcw,
  Bell,
  Monitor,
  Plus,
  X,
  Loader2,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, PolicyConfig, RoleName } from '../../types';
import { api } from '../../api';

const ROLE_ORDER: RoleName[] = ['STUDENT', 'LECTURER', 'ADMINISTRATOR'];

const ACTION_ORDER: Array<keyof PolicyConfig['matrix'][RoleName]> = ['read', 'write', 'delete', 'approve'];

// Risk-weighted color per action - used only when the permission is ON.
// This is what makes it a heatmap rather than a plain checkbox grid: a role
// with delete/approve enabled glows hotter than one with only read enabled,
// so real exposure is visible at a glance rather than requiring you to read
// every cell.
const ACTION_COLOR: Record<string, string> = {
  read: '#45f0cf',
  write: '#f8b25a',
  delete: '#ff8a75',
  approve: '#ff5252',
};

const ACTION_LABEL: Record<string, string> = {
  read: 'Read',
  write: 'Write',
  delete: 'Delete',
  approve: 'Approve',
};

function policyEquals(a: PolicyConfig | null, b: PolicyConfig | null): boolean {
  if (!a || !b) return a === b;
  return JSON.stringify(a) === JSON.stringify(b);
}

export function RoleManagementScreen({
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
    { view: 'role-management', label: 'Access Control', icon: <ShieldCheck size={20} /> },
    { view: 'audit-logs', label: 'Audit Logs', icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savedPolicy, setSavedPolicy] = useState<PolicyConfig | null>(null);
  const [draft, setDraft] = useState<PolicyConfig | null>(null);
  const [selectedRole, setSelectedRole] = useState<RoleName>('STUDENT');
  const [newIpRange, setNewIpRange] = useState('');

  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const loadMatrix = async () => {
    setLoading(true);
    try {
      const res = await api.accessMatrix();
      setSavedPolicy(res.policyConfig);
      setDraft(res.policyConfig);
    } catch (err) {
      openNotice('Unable to load access matrix', err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadMatrix();
  }, []);

  const isDirty = useMemo(() => !policyEquals(draft, savedPolicy), [draft, savedPolicy]);

  const toggleMatrixCell = (role: RoleName, action: keyof PolicyConfig['matrix'][RoleName]) => {
    setDraft((current) => {
      if (!current) return current;
      return {
        ...current,
        matrix: {
          ...current.matrix,
          [role]: {
            ...current.matrix[role],
            [action]: !current.matrix[role][action],
          },
        },
      };
    });
  };

  const updateTimeWindow = (field: 'start' | 'end', value: string) => {
    setDraft((current) => {
      if (!current) return current;
      return {
        ...current,
        environmental: {
          ...current.environmental,
          timeWindow: { ...current.environmental.timeWindow, [field]: value },
        },
      };
    });
  };

  const toggleBlockOutside = () => {
    setDraft((current) => {
      if (!current) return current;
      return {
        ...current,
        environmental: {
          ...current.environmental,
          timeWindow: {
            ...current.environmental.timeWindow,
            blockOutside: !current.environmental.timeWindow.blockOutside,
          },
        },
      };
    });
  };

  const addIpRange = () => {
    const value = newIpRange.trim();
    if (!value) return;
    setDraft((current) => {
      if (!current) return current;
      if (current.environmental.ipRanges.includes(value)) return current;
      return {
        ...current,
        environmental: {
          ...current.environmental,
          ipRanges: [...current.environmental.ipRanges, value],
        },
      };
    });
    setNewIpRange('');
  };

  const removeIpRange = (range: string) => {
    setDraft((current) => {
      if (!current) return current;
      return {
        ...current,
        environmental: {
          ...current.environmental,
          ipRanges: current.environmental.ipRanges.filter((r) => r !== range),
        },
      };
    });
  };

  const handleDiscardChanges = () => {
    setDraft(savedPolicy);
    openNotice('Changes discarded', 'Reverted to the last saved policy configuration.');
  };

  const handleSave = async () => {
    if (!draft) return;
    setSaving(true);
    try {
      const res = await api.updateAccessMatrix(draft);
      setSavedPolicy(res.policyConfig);
      setDraft(res.policyConfig);
      openNotice('Policy saved', 'The access matrix and environmental policy have been redeployed.');
    } catch (err) {
      openNotice('Save failed', err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <Shell
      activeView="role-management"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search access rules..."
      sidebarItems={sidebarItems}
      footerAction={() => onNavigate('dashboard')}
      footerActionClassName="emergency-btn"
      footerActionLabel="Back to Dashboard"
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: 'ADMIN_01', role: 'Security Principal' }}
      topIcons={
        <>
          <button
            className="icon-chip"
            type="button"
            aria-label="Notifications"
            onClick={() => openNotice('Policy status', isDirty ? 'You have unsaved policy changes.' : 'Policy is fully saved.')}
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
            onClick={() => openNotice('Role management console', 'ADMIN_01 | Security Principal')}
          >
            <img alt="profile" src="https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=120&q=80" />
          </button>
        </>
      }
      topbarClassName="role-main"
    >
      <section className="page-stack role-page access-page">
        <div className="role-hero">
          <div className="breadcrumbs">Access Control &gt; <span>Role &amp; Environmental Policy</span></div>
          <div className="role-header-row">
            <div>
              <h1>Access Matrix &amp; Environmental Policy</h1>
              <p>
                Live-editable authorization policy. Changes here are read directly by the tri-layer
                decision engine — the Role layer reads the matrix below, the Context layer reads the
                environmental settings. Nothing on this screen is cosmetic.
              </p>
            </div>
            <div className="role-actions" style={{ alignItems: 'center' }}>
              {isDirty && (
                <span className="unsaved-indicator">Unsaved changes</span>
              )}
              <button className="outlined-btn" type="button" onClick={handleDiscardChanges} disabled={!isDirty || saving}>
                Discard Changes
              </button>
              <button className="primary-mini" type="button" onClick={() => void handleSave()} disabled={!isDirty || saving}>
                {saving ? (<><Loader2 size={15} className="spinning" /> Saving...</>) : 'Save Permissions'}
              </button>
            </div>
          </div>
        </div>

        {loading || !draft ? (
          <div style={{ color: 'var(--muted)', padding: 24 }}>Loading policy configuration...</div>
        ) : (
          <div className="role-grid">
            <section className="panel-card perms-card" style={{ gridColumn: '1 / -1' }}>
              <div className="panel-heading">
                <div className="section-tag outline">ACCESS MATRIX</div>
                <h3>Role Permission Heatmap</h3>
              </div>

              <div style={{ display: 'flex', gap: 10, padding: '18px 20px 0' }}>
                {ROLE_ORDER.map((role) => (
                  <button
                    key={role}
                    type="button"
                    className={`portal-switch-btn`}
                    onClick={() => setSelectedRole(role)}
                    style={{
                      minHeight: 38,
                      padding: '0 16px',
                      borderRadius: 999,
                      border: `1px solid ${selectedRole === role ? 'rgba(77,235,217,0.42)' : 'rgba(255,255,255,0.14)'}`,
                      background: selectedRole === role ? 'rgba(77,235,217,0.12)' : 'rgba(255,255,255,0.03)',
                      color: selectedRole === role ? 'var(--accent)' : '#c9d4e2',
                      fontFamily: 'var(--font-mono)',
                      fontSize: '0.76rem',
                      letterSpacing: '0.08em',
                      textTransform: 'uppercase',
                    }}
                  >
                    {role}
                  </button>
                ))}
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14, padding: 20 }}>
                {ACTION_ORDER.map((action) => {
                  const value = draft.matrix[selectedRole][action];
                  const color = ACTION_COLOR[action];
                  return (
                    <button
                      key={action}
                      type="button"
                      onClick={() => toggleMatrixCell(selectedRole, action)}
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: 10,
                        padding: '20px 12px',
                        borderRadius: 12,
                        cursor: 'pointer',
                        border: `1px solid ${value ? color : 'rgba(255,255,255,0.1)'}`,
                        background: value ? `${color}22` : 'rgba(255,255,255,0.02)',
                        boxShadow: value ? `0 0 18px ${color}40` : 'none',
                        transition: 'all 0.25s ease',
                      }}
                    >
                      <span style={{
                        width: 34, height: 34, borderRadius: '50%',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        background: value ? color : 'rgba(255,255,255,0.08)',
                        color: value ? '#03111b' : 'var(--muted)',
                        fontFamily: 'var(--font-mono)', fontSize: 12, fontWeight: 700,
                      }}>
                        {value ? 'ON' : 'OFF'}
                      </span>
                      <span style={{ fontFamily: 'var(--font-mono)', fontSize: '0.78rem', letterSpacing: '0.08em', color: value ? color : 'var(--muted)' }}>
                        {ACTION_LABEL[action]}
                      </span>
                    </button>
                  );
                })}
              </div>

              <div style={{ padding: '0 20px 18px', fontSize: 12, color: 'var(--muted)' }}>
                {selectedRole} currently has {ACTION_ORDER.filter((a) => draft.matrix[selectedRole][a]).length} of 4 permissions enabled.
                Click a tile to toggle it in this draft, then Save Permissions to deploy.
              </div>
            </section>

            <section className="panel-card constraints-card" style={{ gridColumn: '1 / -1' }}>
              <div className="panel-heading">
                <div className="section-tag dotted">ENVIRONMENTAL POLICY</div>
                <h3>Context Layer Constraints</h3>
              </div>

              <div className="constraints-stack">
                <div className="constraint-box">
                  <div className="constraint-head">
                    <strong>Allowed IP Ranges</strong>
                  </div>
                  <div className="chip-row">
                    {draft.environmental.ipRanges.length === 0 && (
                      <span style={{ fontSize: 12, color: 'var(--muted)' }}>
                        No IP restriction configured — all client IPs are currently permitted.
                      </span>
                    )}
                    {draft.environmental.ipRanges.map((range) => (
                      <span className="chip chip-removable" key={range}>
                        {range}
                        <button type="button" onClick={() => removeIpRange(range)} aria-label={`Remove ${range}`}>
                          <X size={12} />
                        </button>
                      </span>
                    ))}
                  </div>
                  <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
                    <input
                      className="mini-input"
                      style={{ flex: 1 }}
                      placeholder="e.g. 10.0.0.0/8"
                      value={newIpRange}
                      onChange={(e) => setNewIpRange(e.target.value)}
                      onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addIpRange(); } }}
                    />
                    <button type="button" className="add-chip" onClick={addIpRange} aria-label="Add IP range">
                      <Plus size={16} />
                    </button>
                  </div>
                </div>

                <div className="constraint-box">
                  <div className="constraint-head">
                    <strong>Grading Time Window</strong>
                  </div>
                  <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
                    <label style={{ display: 'flex', flexDirection: 'column', gap: 6, fontSize: 11, color: 'var(--muted)', fontFamily: 'var(--font-mono)' }}>
                      START
                      <input
                        type="time"
                        className="mini-input"
                        value={draft.environmental.timeWindow.start}
                        onChange={(e) => updateTimeWindow('start', e.target.value)}
                      />
                    </label>
                    <label style={{ display: 'flex', flexDirection: 'column', gap: 6, fontSize: 11, color: 'var(--muted)', fontFamily: 'var(--font-mono)' }}>
                      END
                      <input
                        type="time"
                        className="mini-input"
                        value={draft.environmental.timeWindow.end}
                        onChange={(e) => updateTimeWindow('end', e.target.value)}
                      />
                    </label>
                  </div>
                  <div className="constraint-foot">
                    <p style={{ color: 'var(--muted)', fontSize: 13 }}>
                      When enabled, grade write/submit/approve actions outside this window are denied
                      at the Context layer.
                    </p>
                    <button
                      type="button"
                      className={`toggle ${draft.environmental.timeWindow.blockOutside ? 'on' : ''}`}
                      onClick={toggleBlockOutside}
                      aria-pressed={draft.environmental.timeWindow.blockOutside}
                      aria-label="Toggle block outside window"
                    >
                      <span />
                    </button>
                  </div>
                </div>
              </div>
            </section>

            <section className="panel-card health-card" style={{ gridColumn: '1 / -1' }}>
              <div className="panel-heading">
                <h3>Policy Health Scan</h3>
              </div>
              <div className="health-row"><span>Emergency Lockout</span><strong>Managed from Dashboard / Course Detail</strong></div>
              <div className="health-note">
                Matrix and environmental settings above are the only policy fields currently read by
                the decision engine. Resource-level per-entity permissions and the associations config
                are not yet consumed by any validator, so they are intentionally not exposed here to
                avoid implying control that doesn't exist.
              </div>
            </section>
          </div>
        )}
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
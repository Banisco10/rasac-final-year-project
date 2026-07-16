import { useEffect, useState } from 'react';
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
  Globe,
  Clock3,
  Database,
  Shield,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem } from '../../types';
import { api } from '../../api';

export function SystemSettingsScreen({
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

  const [stats, setStats] = useState<any>(null);
  const [matrix, setMatrix] = useState<any>(null);
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  const [ipRangesInput, setIpRangesInput] = useState('');
  const [startTimeInput, setStartTimeInput] = useState('08:00');
  const [endTimeInput, setEndTimeInput] = useState('18:00');
  const [blockOutsideInput, setBlockOutsideInput] = useState(true);

  const loadData = () => {
    Promise.all([api.adminStats(), api.accessMatrix()])
      .then(([statsResponse, matrixResponse]) => {
        setStats(statsResponse);
        setMatrix(matrixResponse);
        const config = matrixResponse.policyConfig;
        if (config?.environmental) {
          setIpRangesInput(config.environmental.ipRanges?.join('\n') ?? '');
          setStartTimeInput(config.environmental.timeWindow?.start ?? '08:00');
          setEndTimeInput(config.environmental.timeWindow?.end ?? '18:00');
          setBlockOutsideInput(config.environmental.timeWindow?.blockOutside ?? true);
        }
      })
      .catch(console.error);
  };

  useEffect(() => {
    loadData();
  }, []);

  const roleCount = matrix?.roles?.length ?? 0;
  const permissionCount = matrix?.permissions?.length ?? 0;

  const handleSaveSettings = async () => {
    if (!matrix) return;
    try {
      const updatedConfig = {
        ...matrix.policyConfig,
        environmental: {
          ...matrix.policyConfig.environmental,
          ipRanges: ipRangesInput.split('\n').map((s: string) => s.trim()).filter(Boolean),
          timeWindow: {
            start: startTimeInput,
            end: endTimeInput,
            blockOutside: blockOutsideInput,
          },
        },
      };
      const response = await api.updateAccessMatrix(updatedConfig);
      if (response.success) {
        setMatrix({
          ...matrix,
          policyConfig: response.policyConfig,
        });
        openNotice('System settings saved', 'Operating hours and Network zones were successfully updated on the server.');
      } else {
        openNotice('Save failed', 'Could not save policy config settings.');
      }
    } catch (error) {
      console.error(error);
      openNotice('Error saving settings', error instanceof Error ? error.message : 'Unknown error');
    }
  };

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  return (
    <Shell
      activeView="system-settings"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search system settings..."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
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
      footerUser={{ name: 'ADMIN_01', role: 'Security Principal' }}
      topIcons={
        <>
          <button className="icon-chip" type="button" aria-label="Notifications" onClick={() => openNotice('System summary', `System summary: ${roleCount} roles, ${permissionCount} permissions.`)}>
            <Bell size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Console" onClick={() => onNavigate('audit-logs')}>
            <Monitor size={20} />
          </button>
          <button className="icon-chip" type="button" aria-label="Refresh" onClick={loadData}>
            <RefreshCcw size={20} />
          </button>
          <button className="profile-chip small" type="button" onClick={() => openNotice('System settings', 'ADMIN_01 | Security Principal')}>
            <span className="profile-label">ADMIN_01</span>
          </button>
        </>
      }
      topbarClassName="role-main"
    >
      <section className="page-stack role-page system-settings-page">
        <div className="role-hero">
          <div className="breadcrumbs">Administration &gt; <span>System Settings</span></div>
          <div className="role-header-row">
            <div>
              <h1>System Settings</h1>
              <p>Configure platform-wide defaults, security boundaries, and operational guardrails from a single dedicated page.</p>
            </div>
            <div className="role-actions">
              <button className="outlined-btn" type="button" onClick={loadData}>
                Refresh
              </button>
              <button
                className="primary-mini"
                type="button"
                onClick={handleSaveSettings}
              >
                Save Settings
              </button>
            </div>
          </div>
        </div>

        <div className="role-grid">
          <section className="panel-card perms-card">
            <div className="panel-heading">
              <div className="section-tag outline">OPERATIONAL BASELINE</div>
              <h3>Platform Summary</h3>
            </div>
            <div className="perm-grid">
              {[
                ['Active Period', stats?.activePeriod?.name ?? 'No active period', <Clock3 size={18} />],
                ['Active Sessions', String(stats?.activeSessions ?? 0), <Monitor size={18} />],
                ['Security Events', String(stats?.securityEvents ?? 0), <Shield size={18} />],
                ['Policy Roles', `${roleCount} roles / ${permissionCount} permissions`, <Database size={18} />],
              ].filter(([title, val]) => {
                const text = searchQuery.toLowerCase();
                return title.toLowerCase().includes(text) || String(val).toLowerCase().includes(text);
              }).map(([title, value, icon]) => (
                <div className="perm-card" key={String(title)}>
                  <div>
                    <div className="perm-title">{icon} {title}</div>
                    <div className="perm-desc">{value}</div>
                  </div>
                  <div className="toggle on"><span /></div>
                </div>
              ))}
            </div>
          </section>

          <section className="panel-card rules-card">
            <div className="panel-heading">
              <div className="section-tag dotted">CONTEXT</div>
              <h3>Environment Guardrails</h3>
            </div>
            <div className="rule-list">
              <div className="rule-card cyan">
                <div className="rule-tag">NETWORK ZONES</div>
                <div className="rule-title">Allowed IP Ranges (one per line)</div>
                <textarea
                  className="settings-textarea"
                  value={ipRangesInput}
                  onChange={(e) => setIpRangesInput(e.target.value)}
                  placeholder="No IP restrictions configured."
                  style={{
                    width: '100%',
                    minHeight: '80px',
                    background: 'rgba(0,0,0,0.2)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    color: 'var(--text)',
                    fontFamily: 'var(--font-mono)',
                    fontSize: '13px',
                    padding: '8px',
                    borderRadius: '4px',
                    resize: 'vertical',
                    marginTop: '8px'
                  }}
                />
              </div>
              <div className="rule-card amber">
                <div className="rule-tag amber">TIME WINDOW</div>
                <div className="rule-title">Operating Hours</div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Start:</span>
                    <input
                      type="time"
                      value={startTimeInput}
                      onChange={(e) => setStartTimeInput(e.target.value)}
                      style={{
                        background: 'rgba(0,0,0,0.2)',
                        border: '1px solid rgba(255,255,255,0.1)',
                        color: 'var(--text)',
                        padding: '4px 8px',
                        borderRadius: '4px'
                      }}
                    />
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>End:</span>
                    <input
                      type="time"
                      value={endTimeInput}
                      onChange={(e) => setEndTimeInput(e.target.value)}
                      style={{
                        background: 'rgba(0,0,0,0.2)',
                        border: '1px solid rgba(255,255,255,0.1)',
                        color: 'var(--text)',
                        padding: '4px 8px',
                        borderRadius: '4px'
                      }}
                    />
                  </div>
                  <label style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', cursor: 'pointer', color: 'var(--text)' }}>
                    <input
                      type="checkbox"
                      checked={blockOutsideInput}
                      onChange={(e) => setBlockOutsideInput(e.target.checked)}
                      style={{ cursor: 'pointer' }}
                    />
                    <span>Block grades modification outside hours</span>
                  </label>
                </div>
              </div>
            </div>
          </section>

          <section className="panel-card resource-card">
            <div className="panel-heading">
              <div className="section-tag outline">SYSTEM DEFAULTS</div>
              <h3>Core Settings Inventory</h3>
            </div>
            <div className="resource-table">
              <div className="resource-head">
                <span>Setting</span>
                <span>Value</span>
                <span>Status</span>
                <span>Scope</span>
                <span>Source</span>
                <span>Indicator</span>
              </div>
              {[
                ['Authentication', 'Single sign-on + refresh tokens', 'Enabled', 'Global', 'Auth service', <ShieldCheck size={16} />],
                ['Auditing', 'Security events retained', 'Enabled', 'Global', 'Audit pipeline', <FileText size={16} />],
                ['Geofencing', ipRangesInput ? `${ipRangesInput.split('\n').filter(Boolean).length} range(s)` : 'None', ipRangesInput ? 'Restricted' : 'Open', 'Context', 'Policy config', <Globe size={16} />],
              ].filter(([setting, value, status, scope, source]) => {
                const text = searchQuery.toLowerCase();
                return (
                  setting.toLowerCase().includes(text) ||
                  value.toLowerCase().includes(text) ||
                  status.toLowerCase().includes(text) ||
                  scope.toLowerCase().includes(text) ||
                  source.toLowerCase().includes(text)
                );
              }).map(([setting, value, status, scope, source, indicator]) => (
                <div className="resource-row" key={String(setting)}>
                  <div className="resource-entity">{setting}</div>
                  <div>{value}</div>
                  <div className="resource-id">{status}</div>
                  <div>{scope}</div>
                  <div>{source}</div>
                  <span className="check-box checked">{indicator}</span>
                </div>
              ))}
            </div>
          </section>
        </div>
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

import { useEffect, useMemo, useState } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  Users,
  Shield,
  FileText,
  Plus,
  Bell,
  RefreshCcw,
  Lock,
  Unlock,
  UserX,
  Settings,
  Trash2,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, AuthenticatedUser } from '../../types';
import { api } from '../../api';

type UserRow = {
  id: number;
  fullName: string;
  email: string;
  role: string;
  isActive: boolean;
};

export function UserManagementScreen({
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
    { view: 'role-management', label: 'Access Control', icon: <Shield size={20} /> },
    { view: 'audit-logs', label: 'Audit Logs', icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const [users, setUsers] = useState<UserRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [addUserOpen, setAddUserOpen] = useState(false);
  const [roles, setRoles] = useState<Array<{ id: number; name: string }>>([]);
  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [newUser, setNewUser] = useState({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    roleId: 0,
    studentId: '',
    staffId: '',
    department: 'Computer Science',
  });
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');

  const refresh = async () => {
    setLoading(true);
    try {
      const response = await api.users();
      setUsers(response.data);
    } finally {
      setLoading(false);
    }
  };


  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.accessMatrix().then((res) => {
      setRoles(res.roles);
      const studentRole = res.roles.find((r) => r.name === 'STUDENT');
      if (studentRole) setNewUser((c) => ({ ...c, roleId: studentRole.id }));
    }).catch(console.error);
    refresh().catch(console.error);
  }, []);

  const activeCount = useMemo(() => users.filter((user) => user.isActive).length, [users]);
  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const handleAddUser = async () => {
    try {
      await api.createUser({
        firstName: newUser.firstName.trim(),
        lastName: newUser.lastName.trim(),
        email: newUser.email.trim(),
        password: newUser.password,
        roleId: newUser.roleId,
        studentId: newUser.studentId.trim() || undefined,
        staffId: newUser.staffId.trim() || undefined,
        department: newUser.department.trim() || 'Computer Science',
    });
      setAddUserOpen(false);
      const studentRole = roles.find((r) => r.name === 'STUDENT');
      setNewUser({ firstName: '', lastName: '', email: '', password: '', roleId: studentRole?.id ?? 0, studentId: '', staffId: '', department: 'Computer Science' });
      await refresh();
      setNoticeTitle('User created');
      setNoticeBody('The new account was provisioned successfully.');
      setNoticeOpen(true);
    } catch (err) {
      setNoticeTitle('Failed to create user');
      setNoticeBody(err instanceof Error ? err.message : 'Unknown error');
      setNoticeOpen(true);
    }
  };

  const openUserProfile = (user: UserRow) => {
    setNoticeTitle(user.fullName);
    setNoticeBody(`${user.email}\nRole: ${user.role}\nStatus: ${user.isActive ? 'ACTIVE' : 'LOCKED'}`);
    setNoticeOpen(true);
  };

  const openEmergencyLockoutNotice = async () => {
    try {
      const { emergencyLockoutActive } = await api.accessMatrix();
      await api.toggleEmergencyLockout(!emergencyLockoutActive);
      setNoticeTitle('Emergency lockout updated');
      setNoticeBody(`Emergency lockout ${emergencyLockoutActive ? 'disabled' : 'enabled'}.`);
      setNoticeOpen(true);
    } catch (error) {
      setNoticeTitle('Unable to update emergency lockout');
      setNoticeBody(error instanceof Error ? error.message : 'Unknown error');
      setNoticeOpen(true);
    }
  };
  return (
    <Shell
      activeView="user-management"
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Admin"
      brandSubtitle="HIGHER ED SECURITY"
      searchPlaceholder="Search users by name or email..."
      sidebarItems={sidebarItems}
      footerAction={openEmergencyLockoutNotice}
      footerActionClassName="emergency-btn"
      footerActionLabel="Emergency Lockout"
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: me?.fullName?.toUpperCase() ?? 'ADMIN', role: me?.department ?? 'Security Principal' }}
      topIcons={<><button className="icon-chip" type="button" aria-label="Notifications" onClick={() => openNotice('User inventory', `Active users: ${activeCount}/${users.length}.`)}><Bell size={20} /></button><button className="profile-chip" type="button" onClick={() => openNotice('User management console', 'ADMIN_01 | Security Principal')}><div className="avatar">A</div></button></>}
      topbarClassName="role-main"
    >
      <section className="page-stack role-page">
        <div className="role-hero">
          <div className="breadcrumbs">Administration &gt; <span>User Management</span></div>
          <div className="role-header-row">
            <div>
              <h1>Identity Management</h1>
              <p>Provision and manage higher education personnel accounts. Control active status and oversee institutional role assignments (Requirement 3.5.7).</p>
            </div>
            <div className="role-actions">
              <button className="outlined-btn" type="button" onClick={() => refresh().catch(console.error)}>Refresh</button>
              <button className="primary-mini" type="button" onClick={() => setAddUserOpen(true)}>
                <Plus size={18} /> Add User
              </button>
            </div>
          </div>
        </div>

        <section className="panel-card course-table-card">
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>User Name &amp; Role</th>
                  <th>Email Address</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {users.map((u) => (
                  <tr key={u.id}>
                    <td>
                      <div className="student-name">{u.fullName}</div>
                      <div className="student-id" style={{ fontSize: '11px' }}>{u.role}</div>
                    </td>
                    <td style={{ fontFamily: 'var(--font-mono)', fontSize: '13px' }}>{u.email}</td>
                    <td><span className={`pill ${u.isActive ? 'ok' : 'deny'}`}>{u.isActive ? 'ACTIVE' : 'LOCKED'}</span></td>
                    <td>
                      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                        <button
                          className="view-btn"
                          type="button"
                          disabled={u.role === 'ADMINISTRATOR'}
                          onClick={() => api.updateUser(u.id, { isActive: !u.isActive }).then(refresh).catch(console.error)}
                        >
                          {u.isActive ? <Lock size={14} /> : <Unlock size={14} />} {u.isActive ? 'LOCK' : 'UNLOCK'}
                        </button>
                        <button className="view-btn" type="button" onClick={() => openUserProfile(u)}>
                          VIEW
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div style={{ padding: '14px 18px', color: 'var(--muted)', fontSize: 13 }}>
            {loading ? 'Refreshing users...' : `${activeCount} active users out of ${users.length}.`}
          </div>
        </section>
      </section>

      <Modal
        open={addUserOpen}
        title="Create user account"
        description="Provision a new account without leaving the page."
        onClose={() => setAddUserOpen(false)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setAddUserOpen(false)}>Cancel</button>
            <button type="button" className="primary-mini" onClick={() => handleAddUser().catch(console.error)}>Create User</button>
          </>
        )}
      >
        <div className="modal-form-grid">
          <label className="modal-field">
            <span>First name</span>
            <input value={newUser.firstName} onChange={(e) => setNewUser((c) => ({ ...c, firstName: e.target.value }))} />
          </label>
          <label className="modal-field">
            <span>Last name</span>
            <input value={newUser.lastName} onChange={(e) => setNewUser((c) => ({ ...c, lastName: e.target.value }))} />
          </label>
          <label className="modal-field modal-span-2">
            <span>Email</span>
            <input value={newUser.email} onChange={(e) => setNewUser((c) => ({ ...c, email: e.target.value }))} />
          </label>
          <label className="modal-field">
            <span>Temporary password</span>
            <input type="password" value={newUser.password} onChange={(e) => setNewUser((c) => ({ ...c, password: e.target.value }))} />
          </label>
          <label className="modal-field">
            <span>Role</span>
            <select value={newUser.roleId} onChange={(e) => setNewUser((c) => ({ ...c, roleId: Number(e.target.value) }))}>
              {roles.map((r) => (
                <option key={r.id} value={r.id}>{r.name}</option>
              ))}
            </select>
          </label>
          <label className="modal-field">
            <span>Department</span>
            <input value={newUser.department} onChange={(e) => setNewUser((c) => ({ ...c, department: e.target.value }))} />
          </label>
          {roles.find((r) => r.id === newUser.roleId)?.name === 'STUDENT' && (
            <label className="modal-field">
              <span>Student ID</span>
              <input value={newUser.studentId} onChange={(e) => setNewUser((c) => ({ ...c, studentId: e.target.value }))} placeholder="e.g. 11330842" />
            </label>
          )}
          {roles.find((r) => r.id === newUser.roleId)?.name === 'LECTURER' && (
            <label className="modal-field">
              <span>Staff ID</span>
              <input value={newUser.staffId} onChange={(e) => setNewUser((c) => ({ ...c, staffId: e.target.value }))} placeholder="e.g. LEC-003" />
            </label>
          )}
        </div>
      </Modal>

      <Modal
        open={noticeOpen}
        title={noticeTitle}
        description={noticeBody}
        onClose={() => setNoticeOpen(false)}
        footer={(
          <button type="button" className="primary-mini" onClick={() => setNoticeOpen(false)}>Close</button>
        )}
      >
        <div style={{ whiteSpace: 'pre-line', color: 'var(--text-muted)' }}>{noticeBody}</div>
      </Modal>
    </Shell>
  );
}

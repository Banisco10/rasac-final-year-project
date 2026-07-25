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
  Settings,
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
    { view: 'access-control', label: 'Access Control', icon: <Shield size={20} /> },
    { view: 'audit-logs', label: 'Audit Logs', icon: <FileText size={20} /> },
    { view: 'system-settings', label: 'System Settings', icon: <Settings size={20} /> },
  ];

  const [users, setUsers] = useState<UserRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [addUserOpen, setAddUserOpen] = useState(false);
  const [roles, setRoles] = useState<Array<{ id: number; name: string }>>([]);
  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [pendingLockUser, setPendingLockUser] = useState<UserRow | null>(null);
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [submittingUser, setSubmittingUser] = useState(false);
  const [page, setPage] = useState(1);
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
    } catch (error) {
      openNotice('Unable to load users', error instanceof Error ? error.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const confirmLockToggle = () => {
  if (!pendingLockUser) return;
  const target = pendingLockUser;
  const action = target.isActive ? 'lock' : 'unlock';
  api.updateUser(target.id, { isActive: !target.isActive })
    .then(() => {
      setPendingLockUser(null);
      return refresh();
    })
    .catch((error) => {
      setPendingLockUser(null);
      openNotice(
        `Unable to ${action} account`,
        error instanceof Error ? error.message : 'Unknown error'
      );
    });
};

const validateNewUser = () => {
  const errors: Record<string, string> = {};
  if (!newUser.firstName.trim()) errors.firstName = 'First name is required.';
  if (!newUser.lastName.trim()) errors.lastName = 'Last name is required.';

  const email = newUser.email.trim();
  if (!email) {
    errors.email = 'Email is required.';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.email = 'Enter a valid email address.';
  }

  if (!newUser.password) {
    errors.password = 'A temporary password is required.';
  } else if (newUser.password.length < 8) {
    errors.password = 'Password must be at least 8 characters.';
  }

  const selectedRole = roles.find((r) => r.id === newUser.roleId)?.name;
  if (selectedRole === 'STUDENT' && !newUser.studentId.trim()) {
    errors.studentId = 'Student ID is required.';
  }
  if (selectedRole === 'LECTURER' && !newUser.staffId.trim()) {
    errors.staffId = 'Staff ID is required.';
  }

  setFormErrors(errors);
  return Object.keys(errors).length === 0;
};


  useEffect(() => {
    api.me().then(setMe).catch(console.error);
    api.accessMatrix().then((res) => {
      setRoles(res.roles);
      const studentRole = res.roles.find((r) => r.name === 'STUDENT');
      if (studentRole) setNewUser((c) => ({ ...c, roleId: studentRole.id }));
    }).catch(console.error);
    refresh();
  }, []);

  const activeCount = useMemo(() => users.filter((user) => user.isActive).length, [users]);
  const filteredUsers = useMemo(() => {
    const text = searchQuery.toLowerCase().trim();
    if (!text) return users;
    return users.filter((u) =>
      u.fullName.toLowerCase().includes(text) ||
      u.email.toLowerCase().includes(text) ||
      u.role.toLowerCase().includes(text)
    );
  }, [users, searchQuery]);
  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };


  const pageSize = 8;
  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize));
  const safePage = Math.min(page, totalPages);
  const visibleUsers = filteredUsers.slice((safePage - 1) * pageSize, safePage * pageSize);

  useEffect(() => {
    setPage(1);
  }, [searchQuery]);

  const handleAddUser = async () => {
    if (submittingUser) return;
    if (!validateNewUser()) return;
    setSubmittingUser(true);
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
      setFormErrors({});
      await refresh();
      setNoticeTitle('User created');
      setNoticeBody('The new account was provisioned successfully.');
      setNoticeOpen(true);
    } catch (err) {
      setNoticeTitle('Failed to create user');
      setNoticeBody(err instanceof Error ? err.message : 'Unknown error');
      setNoticeOpen(true);
    } finally {
      setSubmittingUser(false);
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
      searchPlaceholder="Search users by name, email, or role..."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
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
        <style>{`
          @keyframes rasac-spin { to { transform: rotate(360deg); } }
          .spin-icon { animation: rasac-spin 0.7s linear infinite; transform-origin: center; }
        `}</style>
        <div className="role-hero">
          <div className="breadcrumbs">Administration &gt; <span>User Management</span></div>
          <div className="role-header-row">
            <div>
              <h1>Identity Management</h1>
              <p>Provision and manage higher education personnel accounts. Control active status and oversee institutional role assignments (Requirement 3.5.7).</p>
            </div>
            <div className="role-actions">
              <button className="outlined-btn" type="button" disabled={loading} onClick={() => refresh()}>
                <RefreshCcw size={16} className={loading ? 'spin-icon' : ''} /> Refresh
              </button>
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
                {visibleUsers.length === 0 && (
                  <tr>
                    <td colSpan={4} style={{ textAlign: 'center', color: 'var(--muted)', padding: 24 }}>
                      {users.length === 0 ? 'No users found.' : 'No users match your search.'}
                    </td>
                  </tr>
                )}
                {visibleUsers.map((u) => (
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
                          onClick={() => setPendingLockUser(u)}
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
          <div className="table-footer">
            <span style={{ color: 'var(--muted)', fontSize: 13 }}>
              {loading
                ? 'Refreshing users...'
                : searchQuery.trim()
                  ? `${filteredUsers.length} of ${users.length} users match your search.`
                  : `${activeCount} active users out of ${users.length}.`}
            </span>
            {totalPages > 1 && (
              <div className="pagination">
                <button
                  type="button"
                  aria-label="Previous users page"
                  disabled={safePage === 1}
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                >
                  &lt;
                </button>
                <button type="button" className="active">{safePage}</button>
                <button
                  type="button"
                  aria-label="Next users page"
                  disabled={safePage === totalPages}
                  onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                >
                  &gt;
                </button>
              </div>
            )}
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
            <button type="button" className="outlined-btn" onClick={() => { setAddUserOpen(false); setFormErrors({}); }}>Cancel</button>
            <button type="button" className="primary-mini" disabled={submittingUser} onClick={() => handleAddUser().catch(console.error)}>
              {submittingUser ? 'Creating…' : 'Create User'}
            </button>
          </>
        )}
      >
        <div className="modal-form-grid">
          <label className="modal-field">
            <span>First name</span>
            <input value={newUser.firstName} onChange={(e) => setNewUser((c) => ({ ...c, firstName: e.target.value }))} />
            {formErrors.firstName && <small style={{ color: 'var(--danger)' }}>{formErrors.firstName}</small>}
          </label>
          <label className="modal-field">
            <span>Last name</span>
            <input value={newUser.lastName} onChange={(e) => setNewUser((c) => ({ ...c, lastName: e.target.value }))} />
            {formErrors.lastName && <small style={{ color: 'var(--danger)' }}>{formErrors.lastName}</small>}
          </label>
          <label className="modal-field modal-span-2">
            <span>Email</span>
            <input value={newUser.email} onChange={(e) => setNewUser((c) => ({ ...c, email: e.target.value }))} />
            {formErrors.email && <small style={{ color: 'var(--danger)' }}>{formErrors.email}</small>}
          </label>
          <label className="modal-field">
            <span>Temporary password</span>
            <input type="password" value={newUser.password} onChange={(e) => setNewUser((c) => ({ ...c, password: e.target.value }))} />
            {formErrors.password && <small style={{ color: 'var(--danger)' }}>{formErrors.password}</small>}
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
              {formErrors.studentId && <small style={{ color: 'var(--danger)' }}>{formErrors.studentId}</small>}
            </label>
          )}
          {roles.find((r) => r.id === newUser.roleId)?.name === 'LECTURER' && (
            <label className="modal-field">
              <span>Staff ID</span>
              <input value={newUser.staffId} onChange={(e) => setNewUser((c) => ({ ...c, staffId: e.target.value }))} placeholder="e.g. LEC-003" />
              {formErrors.staffId && <small style={{ color: 'var(--danger)' }}>{formErrors.staffId}</small>}
            </label>
          )}
        </div>
      </Modal>

      <Modal
        open={Boolean(pendingLockUser)}
        title={pendingLockUser?.isActive ? 'Lock this account?' : 'Unlock this account?'}
        description={pendingLockUser ? `${pendingLockUser.fullName} (${pendingLockUser.email})` : ''}
        onClose={() => setPendingLockUser(null)}
        footer={(
          <>
            <button type="button" className="outlined-btn" onClick={() => setPendingLockUser(null)}>Cancel</button>
            <button type="button" className="primary-mini" onClick={confirmLockToggle}>
              {pendingLockUser?.isActive ? 'Lock Account' : 'Unlock Account'}
            </button>
          </>
        )}
      >
        <p style={{ color: 'var(--text-muted)' }}>
          {pendingLockUser?.isActive
            ? 'This user will be immediately signed out and unable to access the system until unlocked.'
            : 'This user will regain access to the system immediately.'}
        </p>
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

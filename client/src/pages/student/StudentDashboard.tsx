import { useEffect, useMemo, useState } from 'react';
import {
  LayoutDashboard,
  BookOpen,
  Award,
  History,
  CircleHelp,
  Bell,
  Monitor,
  FlaskConical,
  ShieldX, 
  ShieldCheck,
  Loader2,
  Settings,
  GraduationCap,
  Shield,
  DownloadCloud,
  SquareStack,
  ChevronRight,
  RefreshCcw,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { View, NavItem, Grade, Enrollment, AuthenticatedUser, AuditLog } from '../../types';
import { api, getAccessToken } from '../../api';
import { studentSidebarItems } from './studentPortal';
import { DecisionFlowAnimator } from '../../components/DecisionFlowAnimator';
import type { DecisionStep } from '../../components/DecisionFlowAnimator';
import type { PreviousLoginInfo } from '../../../../shared/types.js';


function decodeJwtExp(token: string | null): number | null {
  if (!token) return null;
  try {
    const [, payload] = token.split('.');
    if (!payload) return null;
    const json = JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
    return typeof json.exp === 'number' ? json.exp : null; // exp is seconds since epoch
  } catch {
    return null; // not a JWT, or malformed — fail silently, don't crash the dashboard
  }
}

type Transcript = {
  studentId: number;
  gpa: number;
  totalCredits: number;
  grades: Array<Grade & { course: { id: number; code: string; title: string; credits: number } | null }>;
};

type TestResult = {
  outcome: 'GRANTED' | 'DENIED' | 'ERROR';
  denyLayer: string | null;
  denyReason: string | null;
  resource: string;
  action: string;
  ms: number;
};

const decisionLayerOrder = ['ROLE', 'RELATIONSHIP', 'CONTEXT', 'SOD'] as const;
type DecisionLayer = (typeof decisionLayerOrder)[number];

const decisionLayerDetails: Record<DecisionLayer, string> = {
  ROLE: 'Validating user role permissions',
  RELATIONSHIP: 'Checking enrollment relationship',
  CONTEXT: 'Evaluating policy constraints',
  SOD: 'Conflict-of-interest validation',
};

function buildDecisionSteps(result: TestResult | null): DecisionStep[] {
  const failedLayer = result?.outcome === 'DENIED' ? result.denyLayer : null;
  const failedIndex = failedLayer
    ? decisionLayerOrder.indexOf(failedLayer as DecisionLayer)
    : -1;

  return decisionLayerOrder.map((layer, index) => {
    let status: DecisionStep['status'] = 'pending';

    if (!result) {
      status = 'pending';
    } else if (failedIndex === -1 || index < failedIndex) {
      status = 'pass';
    } else if (index === failedIndex) {
      status = 'fail';
    }

    return {
      label: `${layer} CHECK`,
      status,
      detail: decisionLayerDetails[layer],
    };
  });
}


export function StudentDashboardScreen({
  activeView,
  previousLogin,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  activeView: View;
  previousLogin?: PreviousLoginInfo | null;
  onNavigate: (view: View) => void;
  onLogout: () => void;
}) {
  const [me, setMe] = useState<AuthenticatedUser | null>(null);
  const [grades, setGrades] = useState<Grade[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [activity, setActivity] = useState<AuditLog[]>([]);
  const [transcript, setTranscript] = useState<Transcript | null>(null);
  const [testScenario, setTestScenario] = useState<'own-grade' | 'other-grade' | 'other-course'>('other-grade');
  const [testRunning, setTestRunning] = useState(false);
  const [testResult, setTestResult] = useState<TestResult | null>(null);
  const [pendingDecisionResult, setPendingDecisionResult] = useState<TestResult | null>(null);
  const [decisionSteps, setDecisionSteps] = useState<DecisionStep[]>(() => buildDecisionSteps(null));
  const [flowKey, setFlowKey] = useState(0);
  const [flowAnimationDone, setFlowAnimationDone] = useState(false);
  const [welcomeBannerOpen, setWelcomeBannerOpen] = useState(Boolean(previousLogin?.lastLogin));
  const [searchQuery, setSearchQuery] = useState('');
  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');
  const [ttlSeconds, setTtlSeconds] = useState<number | null>(null);
  const [reauthPending, setReauthPending] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = () => {
  setRefreshing(true);
  Promise.allSettled([
    api.me().then(setMe),
    api.myGrades().then(setGrades),
    api.myEnrollments().then(setEnrollments),
    api.auditMy().then(setActivity),
    api.transcript().then((data) => setTranscript(data as unknown as Transcript)),
  ]).finally(() => setRefreshing(false));
};

  useEffect(() => {
    loadData();
  }, []);


  useEffect(() => {
  const interval = setInterval(() => {
    const expSeconds = decodeJwtExp(getAccessToken());
    setTtlSeconds(expSeconds === null ? null : Math.max(0, expSeconds - Math.floor(Date.now() / 1000)));
  }, 1000);
  return () => clearInterval(interval);
}, []);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const handleReauth = async () => {
  if (reauthPending) return;
  setReauthPending(true);
  try {
    await api.refresh();
    openNotice('Session Refreshed', 'Your session has been successfully renewed. You\'re all set to continue.');
  } catch {
    openNotice('Refresh Failed', 'We couldn\'t renew your session right now. If this keeps happening, please log out and sign back in.');
  } finally {
    setReauthPending(false);
    api.auditMy().then(setActivity).catch(console.error); // refresh events likely show up in the audit trail too
  }
};

  const downloadTranscript = () => {
  if (!transcript) return;
  const blob = new Blob([JSON.stringify(transcript, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = `transcript-${me?.studentId ?? 'student'}.json`;
  anchor.click();
  URL.revokeObjectURL(url);
};

  const MAX_GPA = 4.0;

  const summaryMetrics = useMemo(() => [
    { label: 'CUMULATIVE GPA', value: transcript ? transcript.gpa.toFixed(2) : '3.88', bar: transcript ? Math.min(100, Math.round((transcript.gpa / MAX_GPA) * 100)) : 82 },
    { label: 'TOTAL CREDITS', value: `${transcript?.totalCredits ?? enrollments.length * 3}`, meta: '/ 120', bar: 81 },
    { label: 'ENROLLED COURSES', value: `${String(enrollments.length).padStart(2, '0')}`, bar: 100, segmented: true },
  ], [enrollments.length, transcript]);

  const transcriptGrades: Array<Grade & { course: Transcript['grades'][number]['course'] }> = transcript
    ? transcript.grades
    : grades.map((grade) => ({ ...grade, course: null }));

  
  const gradeRowsAll = transcriptGrades.map((grade) => ({
    courseId: `#${grade.courseId}`,
    subject: grade.course?.title ?? grade.grade,
    status: grade.status,
    value: grade.grade,
  }));

  const filteredGradeRows = gradeRowsAll.filter((row) => {
    const text = searchQuery.toLowerCase();
    return (
      String(row.courseId || '').toLowerCase().includes(text) ||
      String(row.subject || '').toLowerCase().includes(text) ||
      String(row.status || '').toLowerCase().includes(text) ||
      String(row.value || '').toLowerCase().includes(text)
    );
  })
  .slice(0, searchQuery ? undefined : 4);
  

  const activityRowsAll = activity.map((item) => ({
    title: item.outcome,
    body: item.action,
    tag: item.ipAddress ? `IP: ${item.ipAddress}` : '',
    badge: item.resource ? `NODE: ${item.resource}` : '',
    time: new Date(item.timestamp).toLocaleTimeString('en-GB', { hour12: false }),
    tone: item.outcome === 'GRANTED' ? 'success' : 'danger',
  }));

  const filteredActivityRows = activityRowsAll.filter((row) => {
    const text = searchQuery.toLowerCase();
    return (
      String(row.title || '').toLowerCase().includes(text) ||
      String(row.body || '').toLowerCase().includes(text) ||
      String(row.tag || '').toLowerCase().includes(text) ||
      String(row.badge || '').toLowerCase().includes(text)
    );
  })
  .slice(0, searchQuery ? undefined : 3);


  const formatTtl = (s: number | null) => {
  if (s === null) return 'N/A';
  const h = String(Math.floor(s / 3600)).padStart(2, '0');
  const m = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
  const sec = String(s % 60).padStart(2, '0');
  return `${h}:${m}:${sec}`;
};


  const statusItems = [
  { label: 'Permissions Granted', value: `${me?.permissions?.length ?? 0}` },
  { label: 'Access Role', value: me?.role ?? 'STUDENT' },
  { label: 'Session TTL', value: formatTtl(ttlSeconds), tone: ttlSeconds !== null && ttlSeconds < 60 ? 'danger' : undefined },
];
  
  const flowStatusLabel = testRunning
    ? 'ENGINE INITIALIZING / DECISION TRACE ACTIVE'
    : pendingDecisionResult
      ? 'DECISION COMPLETE / FINALIZING RESULTS'
      : 'READY FOR AUTHORIZATION FLOW';

  useEffect(() => {
    if (!flowAnimationDone || !pendingDecisionResult) return;

    setTestResult(pendingDecisionResult);
    setPendingDecisionResult(null);
    setTestRunning(false);
  }, [flowAnimationDone, pendingDecisionResult]);

  const executeAccessTest = async (): Promise<TestResult> => {
    const start = Date.now();

    try {
      if (testScenario === 'own-grade') {
        await api.myGrades();
        return {
          outcome: 'GRANTED',
          denyLayer: null,
          denyReason: null,
          resource: 'grades',
          action: 'read',
          ms: Date.now() - start,
        };
      }

      if (testScenario === 'other-grade') {
        await api.courseGrades(999);
        return {
          outcome: 'GRANTED',
          denyLayer: null,
          denyReason: 'Unexpectedly passed - check relationship policy',
          resource: 'grades',
          action: 'read',
          ms: Date.now() - start,
        };
      }

      await api.course(999);
      return {
        outcome: 'GRANTED',
        denyLayer: null,
        denyReason: 'Unexpectedly passed - check relationship policy',
        resource: 'courses',
        action: 'read',
        ms: Date.now() - start,
      };
    } catch (err) {
      const error = err as Error & { status?: number };
      const status = error.status ?? 0;
      const denyLayer =
        status === 403
          ? testScenario === 'own-grade'
            ? 'ROLE'
            : 'RELATIONSHIP'
          : status === 401
            ? 'ROLE'
            : status === 404
            ? 'RELATIONSHIP'
            : 'CONTEXT';

      return {
        outcome: 'DENIED',
        denyLayer,
        denyReason: error.message ?? 'Access denied by policy engine',
        resource: testScenario === 'own-grade' ? 'grades' : testScenario === 'other-grade' ? 'grades' : 'courses',
        action: 'read',
        ms: Date.now() - start,
      };
    } finally {
      api.auditMy().then(setActivity).catch(console.error);
    }
  };

  const runAuthorizationFlow = async () => {
    if (testRunning) return;

    setTestRunning(true);
    setTestResult(null);
    setPendingDecisionResult(null);
    setFlowAnimationDone(false);
    setDecisionSteps(buildDecisionSteps(null));
    setFlowKey((current) => current + 1);

    const result = await executeAccessTest();
    setPendingDecisionResult(result);
    setDecisionSteps(buildDecisionSteps(result));
  };

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="STUDENT PORTAL"
      searchPlaceholder="Query system...."
      searchValue={searchQuery}
      onSearchChange={setSearchQuery}
      sidebarItems={studentSidebarItems}
      footerAction={() => {}}
      footerActionClassName="deploy-btn"
      footerActionLabel="Deploy Policy"
      footerActionIcon={<Monitor size={16} />}
      showFooterUser={false}
      showSignOut={false}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications" onClick={() => openNotice('Notifications', `Enrolled in ${enrollments.length} courses.`)}><Bell size={20} /></button>
          <button className="icon-chip" aria-label="Refresh" onClick={loadData} disabled={refreshing}>
            <RefreshCcw size={20} className={refreshing ? 'spinning' : ''} />
          </button>
          <button className="icon-chip" aria-label="Console" onClick={() => openNotice('Console Status', `Security constraints verified. GPA: ${transcript ? transcript.gpa.toFixed(2) : 'N/A'}`)}><Monitor size={20} /></button>
          <button className="icon-chip" aria-label="Settings" onClick={() => openNotice('Settings', `Department: ${me?.department ?? 'Computer Science'}`)}><Settings size={20} /></button>
          <div className="student-user-chip" aria-label="Student profile">
            <div className="student-user-copy">
              <strong>{me?.fullName ?? 'A. SOKOLOV'}</strong>
              <span>STUDENT</span>
            </div>
            <div className="student-user-avatar">{me?.fullName?.split(' ').map((part) => part[0]).join('').slice(0, 2) ?? 'AS'}</div>
          </div>
        </>
      }
      topbarClassName="student-main"
      shellClassName="student-shell"
      sidebarClassName="student-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack student-dashboard-page">
        {welcomeBannerOpen && previousLogin && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '16px',
              padding: '14px 18px',
              borderRadius: '8px',
              border: '1px solid var(--border)',
              background: 'var(--panel, rgba(255,255,255,0.03))',
              marginBottom: '4px',
            }}
          >
            <div>
              <strong style={{ color: 'var(--text)' }}>Welcome back, {me?.fullName ?? 'Student'}</strong>
              <p style={{ color: 'var(--muted)', margin: '2px 0 0', fontSize: '13px' }}>
                Last login: {previousLogin.lastLogin ? new Date(previousLogin.lastLogin).toLocaleString() : 'first recorded login'}
              </p>
              {previousLogin.ipAddress && (
                <p style={{ color: 'var(--muted)', margin: '2px 0 0', fontSize: '13px' }}>
                  Station IP: {previousLogin.ipAddress}
                </p>
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
        <div className="student-top-grid">
          <article className="panel-card student-summary-card">
            <div className="panel-heading student-panel-heading">
              <div>
                <div className="section-tag outline student-tag">STUDENT PROFILE</div>
                <h1>Academic Performance Overview</h1>
              </div>
              <div className="student-cap"><GraduationCap size={28} /></div>
            </div>

            <div className="student-metrics">
              {summaryMetrics.map((metric) => (
                <div className="student-metric" key={metric.label}>
                  <div className="student-metric-label">{metric.label}</div>
                  <div className="student-metric-value-row">
                    <strong>{metric.value}</strong>
                    {metric.meta && <span>{metric.meta}</span>}
                  </div>
                  <div className={`student-bar ${metric.segmented ? 'segmented' : ''}`}>
                    {metric.segmented ? (
                      Array.from({ length: 5 }).map((_, index) => (
                        <span key={`${metric.label}-${index}`} className="segment" />
                      ))
                    ) : (
                      <span style={{ width: `${metric.bar}%` }} />
                    )}
                  </div>
                </div>
              ))}
            </div>
          </article>

          <aside className="panel-card student-context-card">
            <div className="panel-heading student-context-heading">
              <div className="security-chip"><Shield size={14} /><span>SECURITY CONTEXT</span></div>
              <div className="live-chip"><span />LIVE</div>
            </div>
            <div className="student-context-panel">
              {statusItems.map((item) => (
                <div className="student-context-row" key={item.label}>
                  <span>{item.label}</span>
                  <strong className={item.tone === 'success' ? 'success' : ''}>{item.value}</strong>
                </div>
              ))}
            </div>
            <button
              className="student-context-action"
              type="button"
              onClick={handleReauth}
              disabled={reauthPending}
            >
              {reauthPending ? (
                <><Loader2 size={14} className="spinning" /> Refreshing...</>
              ) : (
                'REFRESH MY SESSION'
              )}
            </button>
            <p style={{ color: 'var(--muted)', fontSize: '12px', margin: '6px 0 0', textAlign: 'center' }}>
              Renews your login so you're not signed out unexpectedly.
            </p>
          </aside>
        </div>

        <div className="student-middle-grid">
          <section className="panel-card student-grades-card">
            <div className="panel-heading student-table-heading">
              <div className="section-inline">
                <Award size={18} />
                <h3>MY GRADES</h3>
              </div>
              <button
                className="inline-link student-transcript-link"
                type="button"
                onClick={() => onNavigate('student-grades')}
              >
                FULL TRANSCRIPT
              </button>
            </div>

            <div className="student-table">
              <div className="student-table-head">
                <span>COURSE_ID</span>
                <span>SUBJECT_NOMINAL</span>
                <span>STATUS</span>
                <span>VALUE</span>
              </div>
              {filteredGradeRows.map((row) => (
                <div className="student-table-row" key={row.courseId}>
                  <strong className="student-course-id">{row.courseId}</strong>
                  <span className="student-course-name">{row.subject}</span>
                  <span className="student-status-badge">{row.status}</span>
                  <strong className="student-grade">{row.value}</strong>
                </div>
              ))}
            </div>
          </section>

          <section className="panel-card student-activity-card">
            <div className="panel-heading student-table-heading">
              <div className="section-inline">
                <History size={18} />
                <h3>RECENT ACTIVITY LOG</h3>
              </div>
              <div className="live-chip"><span />LIVE FEED</div>
            </div>

            <div className="student-activity-list">
              {filteredActivityRows.map((activityItem) => (
                <article className={`student-activity-item ${activityItem.tone}`} key={`${activityItem.title}-${activityItem.time}`}>
                  <div className="student-activity-status">
                    <span className="activity-dot" />
                  </div>
                  <div className="student-activity-copy">
                    <div className="student-activity-head">
                      <strong>{activityItem.title}</strong>
                      <time>{activityItem.time}</time>
                    </div>
                    <p>{activityItem.body}</p>
                    <div className="student-activity-tags">
                      {activityItem.tag && <span>{activityItem.tag}</span>}
                      {activityItem.badge && <span>{activityItem.badge}</span>}
                    </div>
                  </div>
                </article>
              ))}
            </div>

            <button
              className="student-export"
              type="button"
              onClick={downloadTranscript}
            >
              <DownloadCloud size={14} />
              EXPORT TRANSCRIPT_JSON
            </button>
          </section>
        </div>

        <section className="panel-card student-visualizer-card">
          <div className="student-visualizer-grid">
            <div className="student-visualizer-side left">
              <div className="student-mini-pane">
                <span>ROLE: STUDENT</span>
              </div>
            </div>

                        
            <section className="panel-card student-access-test">
              <div className="panel-heading student-panel-heading">
                <div className="section-inline">
                  <FlaskConical size={18} />
                  <h3>TRI-LAYER ACCESS TEST</h3>
                </div>
                <span className="live-chip"><span />LIVE ENGINE</span>
              </div>

              <p className="student-test-description">
                Run a real authorization request against the RASAC engine and watch the tri-layer
                decision play out. Each test fires an actual API call — the result reflects what
                the policy engine decided, not a simulation.
              </p>

              <div className="student-test-scenarios">
                {(
                  [
                    ['own-grade',    'Read my own grades',           'Should pass — student reading personal records',       'PASS'],
                    ['other-grade',  'Read another student\'s grade', 'Should fail — relationship layer blocks cross-access', 'FAIL'],
                    ['other-course', 'Access an unrelated course',   'Should fail — no enrollment relationship exists',      'FAIL'],
                  ] as Array<[typeof testScenario, string, string, string]>
                ).map(([value, label, desc, expected]) => (
                  <button
                    key={value}
                    type="button"
                    className={`student-test-scenario-btn ${testScenario === value ? 'active' : ''}`}
                    onClick={() => { setTestScenario(value); setTestResult(null); }}
                  >
                    <div className="student-test-scenario-top">
                      <strong>{label}</strong>
                      <span className={`student-expected-badge ${expected === 'PASS' ? 'pass' : 'fail'}`}>
                        {expected}
                      </span>
                    </div>
                    <p>{desc}</p>
                  </button>
                ))}
              </div>

              <button
                type="button"
                className="primary-mini student-test-run-btn"
                onClick={runAuthorizationFlow}
                disabled={testRunning}
              >
                {testRunning ? (
                  <><Loader2 size={15} className="spinning" /> Running authorization flow...</>
                ) : (
                  <><FlaskConical size={15} /> Run Authorization Flow</>
                )}
              </button>

              <div
                className={`student-flow-status ${testRunning ? 'live' : pendingDecisionResult ? 'finalizing' : 'idle'}`}
                aria-live="polite"
              >
                <span className="student-flow-status-dot" />
                <span>{flowStatusLabel}</span>
              </div>

              {(testRunning || pendingDecisionResult) && (
                <div className="student-flow-wrapper">
                  <DecisionFlowAnimator
                    key={flowKey}
                    steps={decisionSteps}
                    speed={600}
                    onComplete={() => setFlowAnimationDone(true)}
                  />
                </div>
              )}

              {testResult && (
                <div className={`student-test-result ${testResult.outcome === 'GRANTED' ? 'granted' : 'denied'}`}>
                  <div className="student-test-result-header">
                    {testResult.outcome === 'GRANTED'
                      ? <ShieldCheck size={20} />
                      : <ShieldX size={20} />
                    }
                    <div>
                      <strong>
                        {testResult.outcome === 'GRANTED' ? 'ACCESS GRANTED' : `ACCESS DENIED — ${testResult.denyLayer ?? 'POLICY'} LAYER`}
                      </strong>
                      <span>{testResult.ms}ms response time</span>
                    </div>
                  </div>

                  <div className="student-test-result-grid">
                    <div className="student-test-result-row">
                      <span>Resource</span>
                      <strong>{testResult.resource}</strong>
                    </div>
                    <div className="student-test-result-row">
                      <span>Action</span>
                      <strong>{testResult.action}</strong>
                    </div>
                    <div className="student-test-result-row">
                      <span>Outcome</span>
                      <strong>{testResult.outcome}</strong>
                    </div>
                    {testResult.denyLayer && (
                      <div className="student-test-result-row">
                        <span>Blocked at</span>
                        <strong>{testResult.denyLayer} CHECK</strong>
                      </div>
                    )}
                    {testResult.denyReason && (
                      <div className="student-test-result-row full">
                        <span>Reason</span>
                        <strong>{testResult.denyReason}</strong>
                      </div>
                    )}
                  </div>

                  <div className="student-test-result-footer">
                    <Shield size={13} />
                    This result has been recorded in your personal audit log.
                  </div>
                </div>
              )}
            </section>

            <div className="student-visualizer-main">
              <div className="student-visualizer-icon"><SquareStack size={24} /></div>
              <h2>Access Logic Visualizer</h2>
              <p>
                Analyze the path of your authorization requests. View the intersection of Role,
                Relationship, and Contextual constraints in real-time.
              </p>
              <div className="student-visualizer-actions">
                <button className="outlined-btn student-secondary" type="button">
                  LEARN MORE <ChevronRight size={16} />
                </button>
              </div>
            </div>

            <div className="student-visualizer-side right">
              <div className="student-mini-pane compact">
                <span>REL: ENROLLED</span>
              </div>
            </div>
          </div>
        </section>

        <footer className="student-footer">
          <div className="student-footer-status">
            <span><i />SYSTEM CORE: ONLINE</span>
            <span><i />POLICY ENGINE: V2.4.0</span>
          </div>
          <div className="student-footer-links">
            <a href="#student-dashboard">PRIVACY_PROTOCOL</a>
            <a href="#student-dashboard">LEGAL_DISCLAIMER</a>
            <a href="#student-dashboard">NODE_HASH: a12</a>
          </div>
        </footer>
      </section>

      <Modal
        open={noticeOpen}
        title={noticeTitle}
        onClose={() => setNoticeOpen(false)}
        footer={<button type="button" className="primary-mini" onClick={() => setNoticeOpen(false)}>Close</button>}
      >
        <div style={{ whiteSpace: 'pre-line', color: 'var(--text-muted)' }}>{noticeBody}</div>
      </Modal>
    </Shell>
  );
}


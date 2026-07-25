import { useEffect, useState } from 'react';
import {
  Shield, UserRound, Lock, ArrowRight,
  X, Copy, Mail, Loader2, FileText, CircleHelp,
} from 'lucide-react';
import { api, setAccessToken } from '../api';
import type { PreviousLoginInfo } from '../../../shared/types.js';

export function LoginScreen({ onEnter }: { onEnter: (role: string, previousLogin?: PreviousLoginInfo | null) => void }) {
  const [liveClock, setLiveClock] = useState(() => new Date());
  const [feedIndex, setFeedIndex] = useState(0);
  const [checkingStep, setCheckingStep] = useState(0);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [recoveryOpen, setRecoveryOpen] = useState(false);
  const [recoveryEmail, setRecoveryEmail] = useState('');
  const [recoveryMessage, setRecoveryMessage] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [connecting, setConnecting] = useState(false);
  const [connectionPhase, setConnectionPhase] = useState('');
  const [failedAttempts, setFailedAttempts] = useState(0);
  const [rememberMe, setRememberMe] = useState(false);

  const feedItems = [
    '[TRI-LAYER] Identity token validated against campus directory.',
    '[STREAM] Policy engine listening for contextual drift.',
    '[GRAPH] Relationship edge resolved for active lecturer/student link.',
    '[SECURE] Session heartbeat confirmed on encrypted node.',
  ];

  useEffect(() => {
    const clockTimer = window.setInterval(() => setLiveClock(new Date()), 1000);
    const feedTimer = window.setInterval(
      () => setFeedIndex((v) => (v + 1) % feedItems.length),
      2600,
    );
    return () => {
      window.clearInterval(clockTimer);
      window.clearInterval(feedTimer);
    };
  }, []);

  // Animate tri-layer steps on mount
  useEffect(() => {
    setCheckingStep(0);
    const timer = setInterval(() => {
      setCheckingStep((prev) => (prev < 5 ? prev + 1 : prev));
    }, 600);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    if (!recoveryOpen) return;
    setRecoveryEmail(email);
    setRecoveryMessage(null);
  }, [recoveryOpen, email]);

  const handleConnect = async () => {
    if (loading || connecting) return;
    if (!email.trim() || !password.trim()) {
      setError('Please enter your email and password.');
      return;
    }
    setError(null);
    setLoading(true);

    try {
      const loginResult = await api.login(email, password, rememberMe);

      // Credentials verified — run connection animation
      setLoading(false);
      setConnecting(true);

      setConnectionPhase('INITIALIZING SECURE LINK...');
      await new Promise((r) => setTimeout(r, 500));

      setConnectionPhase('EXCHANGING HANDSHAKE...');
      await new Promise((r) => setTimeout(r, 500));

      setConnectionPhase('AUTHORIZING NODE...');
      await new Promise((r) => setTimeout(r, 500));

      setConnectionPhase('CONNECTION ESTABLISHED');
      await new Promise((r) => setTimeout(r, 400));

      // Store token and route by role from server response
      setAccessToken(loginResult.accessToken, rememberMe);
      onEnter(loginResult.user.role, loginResult.previousLogin);

    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Authorization failed.';
      setError(message);
      setFailedAttempts((prev) => prev + 1);
      setLoading(false);
      setConnecting(false);
      setConnectionPhase('');
    }
  };

  const handleRecoverKey = async () => {
    const target = recoveryEmail.trim() || email.trim();
    const subject = `RASAC access key recovery request`;
    const body = [
      'Please assist with a secure access key recovery request.',
      '',
      `Account identifier: ${target || '[enter account email or ID]'}`,
      '',
      'Action needed: verify identity and issue reset instructions.',
    ].join('\n');

    try {
      await navigator.clipboard.writeText(`Subject: ${subject}\n\n${body}`);
      setRecoveryMessage('Recovery request copied to clipboard.');
    } catch {
      setRecoveryMessage('Could not access clipboard. Copy the request manually.');
    }
  };

  return (
    <div className="login-shell alt-login-shell">
      <section className="login-visual alt-login-visual">
        <div className="login-scan-line" />
        <div className="login-grid-bg" />
        <div className="login-visual-content">
          <div className="login-visual-header">
            <h2>Governed Access</h2>
            <p>Visualizing the RASAC Tri-Layer Authorization Engine: Validating Identity, Context, and Policy in Real-Time.</p>
          </div>
          
          <svg className="login-visual-svg" viewBox="0 0 400 500">
            {/* Vertical Connector Line */}
            <line className="flow-line" stroke="#1E293B" strokeWidth="2" x1="200" x2="200" y1="50" y2="430" />
            
            {/* Layer 1: ROLE */}
            <g className="node-pulse">
              <rect fill="#0F172A" height="60" rx="4" stroke="#45f0cf" strokeWidth="1" width="140" x="130" y="30" />
              <text className="svg-label-caps font-bold" fill="#45f0cf" textAnchor="middle" x="200" y="60">LAYER 01: ROLE</text>
              <text className="svg-code-md" fill="#d3e4fe" textAnchor="middle" x="200" y="75">RBAC IDENTIFICATION</text>
            </g>
            
            {/* Layer 2: RELATIONSHIP */}
            <g transform="translate(0, 120)">
              <rect fill="#0F172A" height="60" rx="4" stroke="#1E293B" strokeWidth="1" width="180" x="110" y="30" />
              <text className="svg-label-caps" fill="#bbc7df" textAnchor="middle" x="200" y="60">LAYER 02: RELATIONSHIP</text>
              <text className="svg-code-md" fill="#8f9097" textAnchor="middle" x="200" y="75">ReBAC GRAPH TRAVERSAL</text>
            </g>
            
            {/* Layer 3: CONTEXT */}
            <g transform="translate(0, 240)">
              <rect fill="#0F172A" height="60" rx="4" stroke="#1E293B" strokeDasharray="4 2" strokeWidth="1" width="140" x="130" y="30" />
              <text className="svg-label-caps" fill="#bbc7df" textAnchor="middle" x="200" y="60">LAYER 03: CONTEXT</text>
              <text className="svg-code-md" fill="#8f9097" textAnchor="middle" x="200" y="75">ABAC ENVIRONMENT</text>
            </g>
            
            {/* Layer 4: SoD (Separation of Duties) */}
            <g transform="translate(0, 360)">
              <path d="M100 30 L300 30 L310 60 L90 60 Z" fill="#291700" stroke="#ffb95f" strokeWidth="1" />
              <text className="svg-label-caps font-bold" fill="#ffb95f" textAnchor="middle" x="200" y="50">CONFLICT: SoD CHECK</text>
            </g>
            
            {/* Final Grant */}
            <circle className="svg-pulse-circle" cx="200" cy="460" fill="#45f0cf" r="12" />
            <text className="svg-label-caps" fill="#45f0cf" textAnchor="middle" x="200" y="490">ACCESS GRANTED</text>
          </svg>
          
          <div className="login-metrics-grid">
            <div className="login-metric-card">
              <span className="login-metric-label">NETWORK STATUS</span>
              <div className="login-metric-value">
                <div className="status-dot green" />
                <span className="status-text-accent">ENCRYPTED-NODE-04</span>
              </div>
            </div>
            <div className="login-metric-card">
              <span className="login-metric-label">ACTIVE POLICIES</span>
              <div className="login-metric-value">
                <span className="status-text-primary">1,402 RULES</span>
              </div>
            </div>
          </div>
        </div>
        
        <div className="login-visual-brand-img">
          <img
            alt="Cybersecurity"
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuCSPaw-I-xQ-mPlErJM9aNHGK3qJxUO9O7PBCtpKScQ7u6ee4OyjqtWh9AExjpoTAYQLitLs9Y7m2se8FcDJhIBKurpG-46rbIfGPH7XIN0RCWuRxwhn3eTN_PTxZf7W7u7oIYyhz5DtetZwUEr9piBLCE9Glu5i_FhZCUH7RlDCfkHlxxi3w3191P5RHn7XBE2bFBx_ULdJ87w2NJobrm1tubYNah5qsrq5WfV-0y172fNgw9FrJEppb2lR2SYmpd77z6jobs7BfsQ"
          />
        </div>
      </section>

      <section className="login-panel">
        <div className="login-form-card">
          <div className="form-brand">
            <div className="shield-badge"><Shield size={18} /></div>
            <div className="form-brand-text">RASAC Framework</div>
          </div>
          <h2>System Authentication</h2>
          <p>
            Enter your credentials. The system will detect your role and route
            you to the correct portal automatically.
          </p>

         
          {failedAttempts >= 2 && (
            <div className="lockout-alert" id="lockout-alert">
              <Shield size={20} className="lockout-icon" />
              <div>
                <p className="lockout-title">ACCOUNT LOCKOUT RISK</p>
                <p className="lockout-desc">
                  Multiple failed attempts detected from this IP. One attempt remaining before 30-minute lockout.
                </p>
              </div>
            </div>
          )}

          <div className="field">
            <label>Email Address</label>
            <div className="input-box">
              <UserRound size={18} />
              <input
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleConnect()}
                autoComplete="off"
                spellCheck={false}
                placeholder="your.name@rasac.edu"
              />
            </div>
          </div>

          <div className="field field-row">
            <label>Secure Access Key</label>
            <button
              type="button"
              className="inline-link"
              onClick={() => setRecoveryOpen(true)}
            >
              RECOVER KEY
            </button>
          </div>
          <div className="input-box">
            <Lock size={18} />
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleConnect()}
              autoComplete="off"
              spellCheck={false}
            />
          </div>

          <label className="remember-row">
            <input
              type="checkbox"
              checked={rememberMe}
              onChange={(e) => setRememberMe(e.target.checked)}
            />
            <span>Remember terminal session</span>
          </label>

          <button
            className={`primary-cta ${connecting ? 'connecting' : ''} ${loading ? 'loading' : ''}`}
            type="button"
            onClick={handleConnect}
            disabled={loading || connecting}
          >
            {connecting ? (
              <>{connectionPhase}<Loader2 size={18} className="spinner-icon" /></>
            ) : loading ? (
              <>VERIFYING CREDENTIALS...<Loader2 size={18} className="spinner-icon" /></>
            ) : (
              <>ESTABLISH CONNECTION<ArrowRight size={18} /></>
            )}
          </button>

          {error && (
            <div style={{
              color: '#ffb0a6',
              marginTop: '12px',
              fontSize: '13px',
              fontFamily: 'var(--font-mono)',
            }}>
              {error}
            </div>
          )}

          <div className="portal-note">
            Your role is detected automatically from the institutional directory.
            Contact your administrator if you cannot access the correct portal.
          </div>

          <footer className="login-footer">

            <div className="login-links">
              <a href="#" className="login-link-item group" onClick={(e) => e.preventDefault()}>
                <FileText size={18} />
                <span>Review System Documentation</span>
                <ArrowRight size={14} className="arrow-icon" />
              </a>
              <a href="#" className="login-link-item" onClick={(e) => e.preventDefault()}>
                <CircleHelp size={18} />
                <span>Contact Network Security Operations (NSOC)</span>
              </a>
            </div>
          </footer>
        </div>
      </section>

      {recoveryOpen && (
        <div className="recovery-overlay" role="dialog" aria-modal="true" aria-labelledby="recovery-title">
          <div className="recovery-card">
            <div className="recovery-header">
              <div>
                <div className="recovery-kicker">Recovery channel</div>
                <h3 id="recovery-title">Recover secure access key</h3>
              </div>
              <button
                type="button"
                className="recovery-close"
                onClick={() => setRecoveryOpen(false)}
                aria-label="Close recovery dialog"
              >
                <X size={18} />
              </button>
            </div>
            <p className="recovery-copy">
              We do not reset credentials directly from the login screen. Use this
              prompt to prepare a verified request and send it through the approved
              NSOC workflow.
            </p>
            <div className="recovery-field">
              <label htmlFor="recovery-email">Account email or ID</label>
              <div className="input-box recovery-input">
                <Mail size={18} />
                <input
                  id="recovery-email"
                  value={recoveryEmail}
                  onChange={(e) => setRecoveryEmail(e.target.value)}
                  placeholder="name@rasac.edu"
                  autoComplete="off"
                  spellCheck={false}
                />
              </div>
            </div>
            <div className="recovery-notes">
              <span>Action: identity verification and password reset</span>
            </div>
            {recoveryMessage && (
              <div className="recovery-status">{recoveryMessage}</div>
            )}
            <div className="recovery-actions">
              <button type="button" className="secondary-cta" onClick={handleRecoverKey}>
                <Copy size={16} />
                COPY REQUEST
              </button>
              <button type="button" className="primary-cta" onClick={() => setRecoveryOpen(false)}>
                CLOSE
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
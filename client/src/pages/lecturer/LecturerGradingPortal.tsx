import { useEffect, useMemo, useState, type FormEvent } from 'react';
import {
  LayoutDashboard,
  NotebookPen,
  UserRound,
  FileText,
  Bell,
  Monitor,
  Settings,
  ChevronDown,
  AlertTriangle,
  BookOpen,
  Users,
  Loader2,
  Eye,
  RefreshCcw,
  CheckCircle2,
  Clock3,
  Save,
  Send,
} from 'lucide-react';
import { Shell } from '../../components/Shell';
import { Modal } from '../../components/Modal';
import type { AcademicPeriod, View, NavItem, Course, Grade, AuthenticatedUser } from '../../types';
import { api } from '../../api';
import { DecisionFlowAnimator } from '../../components/DecisionFlowAnimator';
import type { DecisionStep } from '../../components/DecisionFlowAnimator';
import type { DecisionTraceStep } from '../../types';

type CourseMember = {
  id: number;
  fullName: string;
  email: string;
  role: string;
  studentId?: string | null;
  staffId?: string | null;
  department?: string | null;
  isActive: boolean;
};

type SelectedCourse = {
  course: Course;
  lecturer: AuthenticatedUser | null;
  students: CourseMember[];
};

function formatDate(value?: string | null) {
  if (!value) return '--';
  return new Date(value).toLocaleDateString();
}

function formatDateTime(value?: string | null) {
  if (!value) return '--';
  return new Date(value).toLocaleString();
}

function previewLetterGrade(score: number) {
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

function gradeTone(status: Grade['status']) {
  if (status === 'APPROVED') return 'ok';
  if (status === 'SUBMITTED') return 'warn';
  if (status === 'REJECTED') return 'deny';
  return 'info';
}

const gradingDecisionLayerOrder = ['ROLE', 'RELATIONSHIP', 'CONTEXT', 'SOD'] as const;
type GradingDecisionLayer = (typeof gradingDecisionLayerOrder)[number];

const gradingDecisionLayerDetails: Record<GradingDecisionLayer, string> = {
  ROLE: 'Validating lecturer role permissions',
  RELATIONSHIP: 'Confirming you are assigned to this course',
  CONTEXT: 'Checking the grading window is open',
  SOD: 'Checking you are not approving your own submission',
};

function buildGradeDecisionSteps(trace: DecisionTraceStep[] | null): DecisionStep[] {
  return gradingDecisionLayerOrder.map((layer) => {
    const step = trace?.find((s) => s.layer === layer);
    if (!step) {
      return { label: `${layer} CHECK`, status: 'pending', detail: gradingDecisionLayerDetails[layer] };
    }
    return {
      label: `${layer} CHECK`,
      status: step.result === 'PASS' ? 'pass' : 'fail',
      detail: step.reason ?? gradingDecisionLayerDetails[layer],
    };
  });
}

export function LecturerGradingPortalScreen({
  activeView,
  onNavigate,
  onLogout,
}: {
  signedIn: boolean;
  activeView: View;
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
  const [activePeriod, setActivePeriod] = useState<AcademicPeriod | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedCourseId, setSelectedCourseId] = useState<number | null>(null);
  const [courseDetails, setCourseDetails] = useState<SelectedCourse | null>(null);
  const [students, setStudents] = useState<CourseMember[]>([]);
  const [courseGrades, setCourseGrades] = useState<Grade[]>([]);
  const [selectedStudentId, setSelectedStudentId] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [remarks, setRemarks] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [loadingCourse, setLoadingCourse] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [noticeOpen, setNoticeOpen] = useState(false);
  const [noticeTitle, setNoticeTitle] = useState('');
  const [noticeBody, setNoticeBody] = useState('');

  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [previewSteps, setPreviewSteps] = useState<DecisionStep[]>([]);
  const [previewFlowKey, setPreviewFlowKey] = useState(0);
  const [previewOutcome, setPreviewOutcome] = useState<{ granted: boolean; denyReason: string | null } | null>(null);
  const [previewAnimationDone, setPreviewAnimationDone] = useState(false);

  const openNotice = (title: string, body: string) => {
    setNoticeTitle(title);
    setNoticeBody(body);
    setNoticeOpen(true);
  };

  const rejectedGrades = courseGrades.filter((g) => g.status === 'REJECTED');

  const displayName = me?.fullName ?? 'Lecturer';
  const initials = displayName
    .split(' ')
    .map((name) => name[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

  useEffect(() => {
    let cancelled = false;

    const bootstrap = async () => {
      try {
        const [meResponse, coursesResponse, activePeriodResponse] = await Promise.all([
          api.me(),
          api.courses(),
          api.activePeriod(),
        ]);

        if (cancelled) return;

        setMe(meResponse);
        setCourses(coursesResponse.data);
        setActivePeriod(activePeriodResponse);
        setSelectedCourseId(coursesResponse.data[0]?.id ?? null);
      } catch (bootstrapError) {
        if (!cancelled) {
          setError(bootstrapError instanceof Error ? bootstrapError.message : 'Failed to load lecturer portal');
        }
      }
    };

    void bootstrap();

    return () => {
      cancelled = true;
    };
  }, []);

  const refreshSelectedCourse = async (courseId = selectedCourseId) => {
    if (!courseId) return;

    setLoadingCourse(true);
    setError(null);

    try {
      const [courseResponse, studentsResponse, gradesResponse] = await Promise.all([
        api.course(courseId),
        api.courseStudents(courseId),
        api.courseGrades(courseId),
      ]);

      const studentData = studentsResponse.data as CourseMember[];
      setCourseDetails({
        course: courseResponse.course,
        lecturer: courseResponse.lecturer,
        students: studentData,
      });
      setStudents(studentData);
      setCourseGrades(gradesResponse.data);

      setSelectedStudentId((current) => {
        if (current && studentData.some((student) => student.id === current)) {
          return current;
        }
        return studentData[0]?.id ?? null;
      });
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'Failed to load course grading data');
    } finally {
      setLoadingCourse(false);
    }
  };

  useEffect(() => {
    void refreshSelectedCourse();
  }, [selectedCourseId]);

  const selectedCourse = courses.find((course) => course.id === selectedCourseId) ?? courseDetails?.course ?? null;
  const selectedStudent = students.find((student) => student.id === selectedStudentId) ?? null;
  const selectedStudentGrades = useMemo(
    () =>
      courseGrades
        .filter((grade) => grade.studentId === selectedStudentId)
        .sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime()),
    [courseGrades, selectedStudentId],
  );
  const selectedStudentLatestGrade = selectedStudentGrades[0] ?? null;

  const gradeSummary = useMemo(() => {
    const total = courseGrades.length;
    const approved = courseGrades.filter((grade) => grade.status === 'APPROVED').length;
    const submitted = courseGrades.filter((grade) => grade.status === 'SUBMITTED').length;
    const draft = courseGrades.filter((grade) => grade.status === 'DRAFT').length;
    const rejected = courseGrades.filter((grade) => grade.status === 'REJECTED').length;
    const averageScore = total
      ? Math.round(courseGrades.reduce((sum, grade) => sum + grade.score, 0) / total)
      : null;

    return {
      total,
      approved,
      submitted,
      draft,
      rejected,
      averageScore,
      pendingAction: draft + submitted,
    };
  }, [courseGrades]);

  const gradeRecords = useMemo(
    () =>
      [...courseGrades].sort((a, b) => new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime()),
    [courseGrades],
  );

  const isWindowOpen = useMemo(() => {
    if (!activePeriod) return false;
    const now = Date.now();
    return now >= new Date(activePeriod.gradingOpen).getTime() && now <= new Date(activePeriod.gradingClose).getTime();
  }, [activePeriod]);

  const handleCreateGrade = async (mode: 'draft' | 'submit') => {
    if (!selectedCourseId || !selectedStudentId) {
      openNotice('Selection Required', 'Please select a course and student before saving a grade.');
      return;
    }

    if (mode === 'submit' && !isWindowOpen) {
      openNotice(
        'Grading Window Closed',
        activePeriod
          ? `${activePeriod.name} is closed for submissions from ${formatDate(activePeriod.gradingOpen)} to ${formatDate(activePeriod.gradingClose)}. Save a draft instead, or submit once the grading window opens.`
          : 'There is no active grading period right now. Save a draft instead, or submit once a grading window is open.',
      );
      return;
    }

    setSubmitting(true);
    try {
      const created = (await api.createGrade({
        studentId: selectedStudentId,
        courseId: selectedCourseId,
        score,
        remarks,
      })) as Grade;

      if (mode === 'submit') {
        await api.submitGrade(created.id);
      }

      await refreshSelectedCourse(selectedCourseId);
      setRemarks('');
      openNotice(
        mode === 'submit' ? 'Grade Submitted' : 'Draft Saved',
        mode === 'submit' ? 'Grade submitted to the course record.' : 'Grade draft saved.',
      );
    } catch (submitError) {
      openNotice(
        'Error Saving Grade',
        `Unable to save grade: ${submitError instanceof Error ? submitError.message : 'Unknown error'}`,
      );
    } finally {
      setSubmitting(false);
    }
  };

  const handleOpenPreview = async () => {
  if (!selectedCourseId) {
    openNotice('Selection Required', 'Please select a course before previewing the access decision.');
    return;
  }

  setPreviewOpen(true);
  setPreviewLoading(true);
  setPreviewOutcome(null);
  setPreviewAnimationDone(false);
  setPreviewSteps([]);
  setPreviewFlowKey((current) => current + 1);

  try {
    const decision = await api.simulateAccess('grades', 'submit', { targetCourseId: selectedCourseId });
    const failedStep = decision.trace.find((s) => s.result === 'FAIL');
    setPreviewSteps(buildGradeDecisionSteps(decision.trace));
    setPreviewOutcome({
      granted: decision.granted,
      denyReason: failedStep?.reason ?? decision.denyReason ?? null,
    });
  } catch (err) {
    setPreviewOpen(false);
    openNotice('Preview Failed', err instanceof Error ? err.message : 'Unable to run access preview.');
  } finally {
    setPreviewLoading(false);
  }
};

  const selectedCourseLabel = selectedCourse ? `${selectedCourse.code} - ${selectedCourse.title}` : 'Select a course';

  return (
    <Shell
      activeView={activeView}
      onNavigate={onNavigate}
      onLogout={onLogout}
      brandTitle="RASAC Framework"
      brandSubtitle="GRADE MANAGEMENT"
      searchPlaceholder="Search courses or students..."
      sidebarItems={sidebarItems}
      footerAction={() => refreshSelectedCourse().catch(console.error)}
      footerActionClassName="deploy-btn"
      footerActionLabel="Refresh Course"
      footerActionIcon={<RefreshCcw size={16} />}
      footerUser={{ name: displayName.toUpperCase(), role: me?.department ?? 'Lecturer' }}
      topIcons={
        <>
          <button className="icon-chip" aria-label="Notifications">
            <Bell size={20} />
          </button>
          <button className="icon-chip" aria-label="Console">
            <Monitor size={20} />
          </button>
          <button className="icon-chip" aria-label="Settings">
            <Settings size={20} />
          </button>
          <div className="student-user-chip lecturer-chip" aria-label="Lecturer profile">
            <div className="student-user-copy">
              <strong>{displayName.toUpperCase()}</strong>
              <span>LECTURER</span>
            </div>
            <div className="student-user-avatar">{initials}</div>
          </div>
        </>
      }
      topbarClassName="portal-main grading-main"
      shellClassName="grading-shell"
      sidebarClassName="grading-sidebar"
      showSidebarLinks={true}
    >
      <section className="page-stack grading-page">
        <header className="grading-header">
          <div className="grading-header-line">
            <span className="label-inline">LECTURER GRADING PORTAL</span>
            <div className="grading-divider" />
          </div>
          <h1>Manage course grades from one place</h1>
          <p>
            Review the assigned course, pick a student, enter the score, and keep the grading record
            up to date with drafts and submissions.
          </p>
        </header>

        {error && (
          <section className="panel-card" role="alert">
            <div className="panel-heading">
              <h3>Unable to load grading data</h3>
            </div>
            <p style={{ margin: 0, color: 'var(--muted)' }}>{error}</p>
          </section>
        )}

        {activePeriod && (
          <section className="portal-banner warning">
            <div>
              <strong>
                {isWindowOpen ? 'Grading window open' : 'Grading window closed'}
              </strong>
              <p>
                {activePeriod.name} runs from {formatDate(activePeriod.gradingOpen)} to {formatDate(activePeriod.gradingClose)}.
                {isWindowOpen
                  ? ' You can save drafts and submit grades for your assigned course.'
                  : ' Submissions are currently outside the active grading period.'}
              </p>
            </div>
            <div className={`status-pill ${isWindowOpen ? 'open' : 'denied'}`}>
              {isWindowOpen ? 'OPEN' : 'CLOSED'}
            </div>
          </section>
        )}

        {rejectedGrades.length > 0 && (
          <div className="grading-warning visible" style={{ borderColor: 'rgba(239,68,68,0.35)', background: 'rgba(239,68,68,0.08)', color: '#fca5a5', marginBottom: 0 }}>
            <AlertTriangle size={18} />
            <div>
              <h4 style={{ color: '#f87171', margin: '0 0 4px' }}>
                {rejectedGrades.length} grade{rejectedGrades.length > 1 ? 's' : ''} rejected — resubmission required
              </h4>
              <p style={{ margin: '0 0 10px' }}>
                The registrar has rejected the following grade{rejectedGrades.length > 1 ? 's' : ''}. Review the record{rejectedGrades.length > 1 ? 's' : ''} in the table below, make any corrections, and resubmit.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                {rejectedGrades.map((grade) => {
                  const student = students.find((s) => s.id === grade.studentId);
                  return (
                    <span
                      key={grade.id}
                      style={{
                        fontSize: 11,
                        fontWeight: 600,
                        padding: '3px 10px',
                        borderRadius: 999,
                        background: 'rgba(239,68,68,0.15)',
                        border: '1px solid rgba(239,68,68,0.3)',
                        color: '#f87171',
                      }}
                    >
                      {student?.fullName ?? `Student #${grade.studentId}`} — {grade.score}%
                    </span>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        <div className="course-metrics">
          <div className="course-metric-card">
            <div className="course-metric-label">COURSE</div>
            <div className="course-metric-value" style={{ fontSize: '1.55rem' }}>
              {selectedCourse?.code ?? '--'}
            </div>
            <div className="course-metric-sub">{selectedCourse?.title ?? 'No course selected'}</div>
          </div>
          <div className="course-metric-card">
            <div className="course-metric-label">ENROLLED STUDENTS</div>
            <div className="course-metric-value">{students.length}</div>
            <div className="course-metric-sub">{courseDetails?.lecturer?.fullName ?? displayName} is assigned</div>
          </div>
          <div className="course-metric-card">
            <div className="course-metric-label">AVERAGE SCORE</div>
            <div className="course-metric-value">{gradeSummary.averageScore ?? '--'}%</div>
            <div className="course-metric-sub">{gradeSummary.total} graded submissions</div>
          </div>
          <div className="course-metric-card status-card">
            <div className="course-metric-label">PENDING ACTIONS</div>
            <div className="status-line">
              <span className="status-dot warning" />
              {gradeSummary.pendingAction} records waiting
            </div>
            <div className="course-metric-sub upper">
              {activePeriod ? `${activePeriod.name}` : 'No active academic period'}
            </div>
          </div>
        </div>

        <div className="grading-layout">
          <aside className="grading-rail">
            <section className="panel-card grading-step-card">
              <div className="panel-heading grading-panel-top">
                <h3>COURSE CONTEXT</h3>
                <BookOpen size={16} />
              </div>
              <div className="grading-steps">
                <div className="grading-step active">
                  <div className="grading-step-dot done">1</div>
                  <div>
                    <strong>Assigned course</strong>
                    <p>Select the module you are grading.</p>
                    <span>{selectedCourseLabel}</span>
                  </div>
                </div>
                <div className="grading-step active">
                  <div className="grading-step-dot done">2</div>
                  <div>
                    <strong>Academic period</strong>
                    <p>Use the active grading window for the current term.</p>
                    <span>{activePeriod ? activePeriod.name : 'Awaiting active period'}</span>
                  </div>
                </div>
                <div className={`grading-step ${selectedStudent ? 'active' : 'muted'}`}>
                  <div className={`grading-step-dot ${selectedStudent ? 'done' : ''}`}>3</div>
                  <div>
                    <strong>Student selected</strong>
                    <p>Choose a student before entering a score.</p>
                    <span>{selectedStudent?.fullName ?? 'No student selected'}</span>
                  </div>
                </div>
              </div>
            </section>

            <section className="panel-card grading-logic-card">
              <div className="panel-heading grading-panel-top">
                <span className="label-inline">COURSE OVERVIEW</span>
                <Users size={16} />
              </div>
              <div className="grading-log">
                <div className="grading-log-row">
                  <span>COURSE</span>
                  <span>{selectedCourseLabel}</span>
                </div>
                <div className="grading-log-row indent">
                  <span>Lecturer</span>
                  <span>{courseDetails?.lecturer?.fullName ?? displayName}</span>
                </div>
                <div className="grading-log-row indent muted">
                  <span>Credits</span>
                  <span>{selectedCourse?.credits ?? '--'}</span>
                </div>
                <div className="grading-log-divider" />
                <div className="grading-log-status">
                  {loadingCourse ? 'Loading course roster and grade records...' : 'Course details and roster are sourced from the backend.'}
                </div>
              </div>
            </section>

            <section className="panel-card grading-logic-card">
              <div className="panel-heading grading-panel-top">
                <span className="label-inline">SELECTED STUDENT</span>
                <UserRound size={16} />
              </div>
              <div className="grading-log">
                <div className="grading-log-row">
                  <span>Name</span>
                  <span>{selectedStudent?.fullName ?? 'Choose a student'}</span>
                </div>
                <div className="grading-log-row indent">
                  <span>ID</span>
                  <span>{selectedStudent?.studentId ?? selectedStudent?.id ?? '--'}</span>
                </div>
                <div className="grading-log-row indent muted">
                  <span>Email</span>
                  <span>{selectedStudent?.email ?? '--'}</span>
                </div>
                <div className="grading-log-divider" />
                <div className="grading-log-status">
                  {selectedStudentLatestGrade
                    ? `Latest record: ${selectedStudentLatestGrade.grade} (${selectedStudentLatestGrade.status})`
                    : 'No grade has been recorded for this student yet.'}
                </div>
              </div>
            </section>
          </aside>

          <section className="panel-card grading-form-card">
            <div className="grading-form-header">
              <h2>
                <NotebookPen size={18} />
                Grade Entry
              </h2>
              <div className="grading-override">
                <span>Preview</span>
                <div className="toggle-pill" aria-hidden="true">
                  <span />
                </div>
              </div>
            </div>

            <form className="grading-form" id="grade-form" onSubmit={(event) => {
              event.preventDefault();
              void handleCreateGrade('submit');
            }}>
              <div className="grading-form-grid">
                <div className="grading-field">
                  <label>Course</label>
                  <div className="grading-select-wrap">
                    <select
                      value={selectedCourseId ?? ''}
                      onChange={(e) => setSelectedCourseId(e.target.value ? Number(e.target.value) : null)}
                    >
                      <option value="">Select course...</option>
                      {courses.map((course) => (
                        <option key={course.id} value={course.id}>
                          {course.code}: {course.title}
                        </option>
                      ))}
                    </select>
                    <ChevronDown size={16} />
                  </div>
                </div>

                <div className="grading-field">
                  <label>Student</label>
                  <div className="grading-select-wrap">
                    <select
                      value={selectedStudentId ?? ''}
                      onChange={(e) => setSelectedStudentId(e.target.value ? Number(e.target.value) : null)}
                    >
                      <option value="">Select student...</option>
                      {students.map((student) => (
                        <option key={student.id} value={student.id}>
                          {student.fullName} {student.studentId ? `(${student.studentId})` : ''}
                        </option>
                      ))}
                    </select>
                    <ChevronDown size={16} />
                  </div>
                </div>

                <div className="grading-field">
                  <label>Numeric Score (0-100)</label>
                  <div className="grading-input-wrap score-wrap">
                    <input
                      type="number"
                      min="0"
                      max="100"
                      value={score}
                      onChange={(e) => setScore(Number(e.target.value))}
                    />
                    <span>%</span>
                  </div>
                </div>

                <div className="grading-field">
                  <label>Grade preview</label>
                  <div className="grading-toggle-row" aria-live="polite">
                    <input readOnly type="checkbox" checked={score >= 50} />
                    <span>
                      {previewLetterGrade(score)} grade preview
                    </span>
                  </div>
                </div>
              </div>

              <div className="grading-field full-width">
                <label>Remarks</label>
                <textarea
                  rows={3}
                  value={remarks}
                  onChange={(e) => setRemarks(e.target.value)}
                  placeholder="Add grading notes, moderation comments, or feedback for the student..."
                />
              </div>

              <div className={`grading-warning ${selectedCourseId && selectedStudentId ? '' : 'visible'}`}>
                <AlertTriangle size={18} />
                <div>
                  <h4>Missing required information</h4>
                  <p>
                    Select both a course and student before saving or submitting a grade.
                  </p>
                </div>
              </div>

              {selectedStudentLatestGrade && (
                <div className="grading-warning visible" style={{ borderColor: 'rgba(69,240,207,0.28)', background: 'rgba(69,240,207,0.08)', color: '#dffbf5' }}>
                  <CheckCircle2 size={18} />
                  <div>
                    <h4 style={{ color: '#9cf5e4' }}>Latest grade on record</h4>
                    <p>
                      {selectedStudentLatestGrade.grade} at {formatDateTime(selectedStudentLatestGrade.submittedAt)}.
                      Status: {selectedStudentLatestGrade.status}.
                    </p>
                  </div>
                </div>
              )}

              <div className="grading-actions">
                <div className="grading-session">
                  <span>Academic period</span>
                  <strong>
                    {activePeriod
                      ? `${activePeriod.name} | ${isWindowOpen ? 'OPEN' : 'CLOSED'}`
                      : 'No active period'}
                  </strong>
                </div>
                <div className="grading-buttons">
                    <button
                      type="button"
                      className="grading-secondary-btn"
                      disabled={!selectedCourseId}
                      onClick={handleOpenPreview}
                    >
                      Preview Access Decision
                      <Eye size={16} />
                    </button>
                    <button type="button" className="grading-secondary-btn" disabled={submitting || !selectedCourseId || !selectedStudentId} onClick={() => handleCreateGrade('draft')}>
                      Save Draft
                      <Save size={16} />
                    </button>
                    <button type="submit" className="primary-mini grading-submit-btn" disabled={submitting || !selectedCourseId || !selectedStudentId || !isWindowOpen}>
                      {submitting ? 'Submitting...' : 'Submit Grade'}
                      <Send size={16} />
                    </button>
                  </div>
              </div>
            </form>
          </section>
        </div>

        <section className="grading-history">
          <div className="panel-heading" style={{ padding: '16px 18px 0' }}>
            <h3>Current Grade Records</h3>
            <button
              type="button"
              className="view-btn"
              onClick={() => refreshSelectedCourse().catch(console.error)}
            >
              REFRESH
            </button>
          </div>
          <div className="table-wrap">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Student</th>
                  <th>Score</th>
                  <th>Grade</th>
                  <th>Status</th>
                  <th>Submitted</th>
                  <th>Notes</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {gradeRecords.length === 0 ? (
                  <tr>
                    <td colSpan={7} style={{ color: 'var(--muted)', textAlign: 'center', padding: 16 }}>
                      No grades yet for this course
                    </td>
                  </tr>
                ) : (
                  gradeRecords.map((grade) => {
                    const student = students.find((entry) => entry.id === grade.studentId);
                    const canSubmit = grade.status === 'DRAFT' || grade.status === 'REJECTED';

                    return (
                      <tr key={grade.id}>
                        <td>
                          <div className="student-name">{student?.fullName ?? `Student #${grade.studentId}`}</div>
                          <div className="student-id">{student?.studentId ?? grade.studentId}</div>
                        </td>
                        <td>{grade.score}</td>
                        <td>{grade.grade}</td>
                        <td>
                          <span className={`pill ${gradeTone(grade.status)}`}>{grade.status}</span>
                        </td>
                        <td>{formatDateTime(grade.submittedAt)}</td>
                        <td style={{ color: 'var(--muted)' }}>{grade.remarks || '--'}</td>
                        <td>
                          {canSubmit ? (
                            <button
                              type="button"
                              className="view-btn"
                              onClick={() =>
                                api.submitGrade(grade.id)
                                  .then(() => refreshSelectedCourse().catch(console.error))
                                  .catch(console.error)
                              }
                            >
                              SUBMIT
                            </button>
                          ) : (
                            <span style={{ color: 'var(--muted)', fontSize: 12 }}>
                              <Clock3 size={14} style={{ verticalAlign: 'text-bottom', marginRight: 6 }} />
                              Locked
                            </span>
                          )}
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          <div style={{ marginTop: 12, color: 'var(--muted)' }}>
            {students.length} students loaded for {selectedCourseLabel}. {gradeSummary.total} grade records found.
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


      <Modal
        open={previewOpen}
        title="Access Decision Preview"
        description={selectedCourse ? `Simulated grades:submit request for ${selectedCourseLabel}` : ''}
        onClose={() => setPreviewOpen(false)}
        footer={<button type="button" className="primary-mini" onClick={() => setPreviewOpen(false)}>Close</button>}
      >
        {previewLoading ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, color: 'var(--muted)', padding: '20px 0' }}>
            <Loader2 size={18} className="spinning" /> Checking access...
          </div>
        ) : previewSteps.length > 0 ? (
          <>
            <DecisionFlowAnimator
              key={previewFlowKey}
              steps={previewSteps}
              speed={550}
              onComplete={() => setPreviewAnimationDone(true)}
            />
            {previewAnimationDone && previewOutcome && (
              <div style={{
                marginTop: 16, padding: 12, borderRadius: 8,
                background: previewOutcome.granted ? 'rgba(69,240,207,0.08)' : 'rgba(239,68,68,0.08)',
                border: `1px solid ${previewOutcome.granted ? 'rgba(69,240,207,0.3)' : 'rgba(239,68,68,0.3)'}`,
              }}>
                <strong style={{ color: previewOutcome.granted ? '#45f0cf' : '#f87171' }}>
                  {previewOutcome.granted ? 'Access would be granted' : 'Access would be denied'}
                </strong>
                {!previewOutcome.granted && previewOutcome.denyReason && (
                  <p style={{ margin: '6px 0 0', color: 'var(--muted)', fontSize: 13 }}>{previewOutcome.denyReason}</p>
                )}
              </div>
            )}
          </>
        ) : null}
      </Modal>
    </Shell>
  );
}

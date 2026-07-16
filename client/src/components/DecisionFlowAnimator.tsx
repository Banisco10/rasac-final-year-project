import { useEffect, useState } from 'react';
import { Check, X } from 'lucide-react';

export type DecisionStep = {
  label: string;
  status: 'pending' | 'pass' | 'fail';
  detail: string;
};

const START_DELAY_MS = 150;

export function DecisionFlowAnimator({
  steps,
  speed = 550,
  onComplete,
}: {
  steps: DecisionStep[];
  speed?: number;
  onComplete?: () => void;
}) {
  const [visibleCount, setVisibleCount] = useState(0);

  useEffect(() => {
    setVisibleCount(0);
    const total = steps.length;
    if (total === 0) return undefined;

    let cancelled = false;
    let i = 0;

    const advance = () => {
      if (cancelled) return;
      i += 1;
      setVisibleCount(i);
      if (i < total) {
        setTimeout(advance, speed);
      } else {
        // Hold on the fully-revealed state for one more beat so the last
        // step's check/cross actually gets a paint before results appear -
        // otherwise this update and the parent's onComplete-triggered
        // result reveal land in the same batch and look simultaneous.
        setTimeout(() => onComplete?.(), speed);
      }
    };

    const timer = setTimeout(advance, START_DELAY_MS);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="dfa-wrap">
      {steps.map((step, i) => {
        const isShown = i < visibleCount;
        const isActive = i === visibleCount - 1;
        const tone = step.status === 'pass' ? 'pass' : step.status === 'fail' ? 'fail' : '';

        const dotBackground =
          step.status === 'pass' ? '#45f0cf' : step.status === 'fail' ? '#f44336' : '#6b7db3';
        const dotIconColor = step.status === 'pass' ? '#03111b' : '#ffffff';

        return (
          <div key={step.label} className="dfa-row">
            <div className={`dfa-step ${tone} ${isShown ? 'done' : ''} ${isActive ? 'active' : ''}`}>
              <div className="dfa-content">
                <strong>{step.label}</strong>
                <span className="dfa-detail">
                  {isShown ? step.detail : 'Waiting…'}
                </span>
              </div>
              <span
                style={{
                  width: 20,
                  height: 20,
                  borderRadius: '50%',
                  flexShrink: 0,
                  marginLeft: 'auto',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  background: dotBackground,
                  color: dotIconColor,
                  transition: 'background 0.3s',
                }}
              >
                {isShown && step.status === 'pass' && <Check size={13} strokeWidth={3} />}
                {isShown && step.status === 'fail' && <X size={13} strokeWidth={3} />}
              </span>
            </div>
            {i < steps.length - 1 && (
              <div className={`dfa-line ${i < visibleCount - 1 ? 'active' : ''}`} />
            )}
          </div>
        );
      })}
    </div>
  );
}
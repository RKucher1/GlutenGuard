import { useState } from 'react'

/* ── Reusable primitives ─────────────────────────────────────────────────── */

function Chip({ label, selected, onClick }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="px-3 py-1.5 rounded-full text-sm transition-all"
      style={{
        background: selected ? 'var(--teal)' : 'var(--bg-card)',
        color: selected ? '#000' : 'var(--text-secondary)',
        border: selected ? '1px solid var(--teal)' : '1px solid var(--border)',
        fontWeight: selected ? 600 : 400,
      }}
    >
      {label}
    </button>
  )
}

function MultiChip({ options, value, onChange }) {
  const toggle = (opt) => {
    if (value.includes(opt)) onChange(value.filter(v => v !== opt))
    else onChange([...value, opt])
  }
  return (
    <div className="flex flex-wrap gap-2">
      {options.map(opt => (
        <Chip key={opt} label={opt} selected={value.includes(opt)} onClick={() => toggle(opt)} />
      ))}
    </div>
  )
}

function SingleChip({ options, value, onChange }) {
  return (
    <div className="flex flex-wrap gap-2">
      {options.map(opt => (
        <Chip key={opt} label={opt} selected={value === opt} onClick={() => onChange(opt)} />
      ))}
    </div>
  )
}

function TextInput({ value, onChange, placeholder, small }) {
  return (
    <input
      value={value}
      onChange={e => onChange(e.target.value)}
      placeholder={placeholder}
      className="rounded-xl outline-none transition-all"
      style={{
        background: 'var(--bg-card)',
        border: '1px solid var(--border)',
        color: 'var(--text-primary)',
        padding: small ? '8px 14px' : '12px 18px',
        fontSize: small ? '13px' : '15px',
        width: '100%',
      }}
      onFocus={e => e.target.style.borderColor = 'var(--teal)'}
      onBlur={e => e.target.style.borderColor = 'var(--border)'}
    />
  )
}

function TimeChip({ options, value, onChange }) {
  return <SingleChip options={options} value={value} onChange={onChange} />
}

/* ── Step definitions ────────────────────────────────────────────────────── */

// Each step returns { isComplete(profile) } so the Next button enables correctly

const STEPS = [
  {
    id: 'welcome',
    emoji: '👋',
    title: "Let's personalise your day",
    subtitle: "Answer a few quick questions so DayForge can build schedules that actually fit your life. Takes about 2 minutes.",
    isComplete: (p) => p.name.trim().length > 0,
    render: (profile, setField) => (
      <div>
        <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>What should I call you?</label>
        <TextInput value={profile.name} onChange={v => setField('name', v)} placeholder="Your first name" />
      </div>
    ),
  },
  {
    id: 'morning',
    emoji: '🌅',
    title: 'Morning routine',
    subtitle: "When does your day actually start?",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>I'm usually up by</label>
          <TimeChip
            options={['5am', '6am', '6:30am', '7am', '7:30am', '8am', '8:30am', '9am', '10am+']}
            value={profile.wakeTime}
            onChange={v => setField('wakeTime', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Breakfast?</label>
          <SingleChip
            options={['Always', 'Sometimes', 'Never', 'Just coffee']}
            value={profile.breakfast}
            onChange={v => setField('breakfast', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Typical start of work</label>
          <TimeChip
            options={['7am', '8am', '8:30am', '9am', '9:30am', '10am', '11am', 'Flexible']}
            value={profile.workStart}
            onChange={v => setField('workStart', v)}
          />
        </div>
      </div>
    ),
  },
  {
    id: 'pets',
    emoji: '🐾',
    title: 'Pets',
    subtitle: "Do you have animals that need care during the day?",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-3" style={{ color: 'var(--text-secondary)' }}>Pets at home</label>
          <MultiChip
            options={['Dog(s)', 'Cat(s)', 'Other', 'No pets']}
            value={profile.pets}
            onChange={v => setField('pets', v)}
          />
        </div>
        {profile.pets.includes('Dog(s)') && (
          <>
            <div>
              <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Dog walks — when? (pick all that apply)</label>
              <MultiChip
                options={['Early morning', 'Morning', 'Midday', 'Afternoon', 'Evening', 'Late night']}
                value={profile.dogWalkTimes}
                onChange={v => setField('dogWalkTimes', v)}
              />
            </div>
            <div>
              <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Typical walk length</label>
              <SingleChip
                options={['10 min', '20 min', '30 min', '45 min', '1 hr+']}
                value={profile.dogWalkDuration}
                onChange={v => setField('dogWalkDuration', v)}
              />
            </div>
          </>
        )}
      </div>
    ),
  },
  {
    id: 'meals',
    emoji: '🍽️',
    title: 'Eating habits',
    subtitle: "Meals are real schedule blocks — let's account for them.",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Lunch — do you cook or prep?</label>
          <SingleChip
            options={['Cook at home', 'Meal prep', 'Order in', 'Skip lunch', 'It varies']}
            value={profile.lunchStyle}
            onChange={v => setField('lunchStyle', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Lunch time</label>
          <TimeChip
            options={['11:30am', '12pm', '12:30pm', '1pm', '1:30pm', '2pm', 'Whenever']}
            value={profile.lunchTime}
            onChange={v => setField('lunchTime', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Dinner time</label>
          <TimeChip
            options={['5pm', '6pm', '6:30pm', '7pm', '7:30pm', '8pm', '9pm+', 'Varies']}
            value={profile.dinnerTime}
            onChange={v => setField('dinnerTime', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Do you cook dinner?</label>
          <SingleChip
            options={['Yes, always', 'Sometimes', 'Rarely', 'Partner cooks', 'Order / takeout']}
            value={profile.dinnerStyle}
            onChange={v => setField('dinnerStyle', v)}
          />
        </div>
      </div>
    ),
  },
  {
    id: 'exercise',
    emoji: '💪',
    title: 'Exercise',
    subtitle: "Workouts are non-negotiable blocks. Where do they fit?",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Do you work out?</label>
          <SingleChip
            options={['Daily', '4–5x / week', '2–3x / week', 'Once a week', 'Rarely', 'Not currently']}
            value={profile.exerciseFreq}
            onChange={v => setField('exerciseFreq', v)}
          />
        </div>
        {profile.exerciseFreq !== 'Not currently' && profile.exerciseFreq !== 'Rarely' && (
          <>
            <div>
              <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Type of workout (pick all)</label>
              <MultiChip
                options={['Gym', 'Run', 'Cycle', 'Home workout', 'Yoga / stretching', 'Sports', 'Walk', 'Other']}
                value={profile.exerciseTypes}
                onChange={v => setField('exerciseTypes', v)}
              />
            </div>
            <div>
              <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Usually when?</label>
              <SingleChip
                options={['Early morning', 'Morning', 'Lunch break', 'Afternoon', 'Evening', 'Varies']}
                value={profile.exerciseTime}
                onChange={v => setField('exerciseTime', v)}
              />
            </div>
            <div>
              <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>How long?</label>
              <SingleChip
                options={['20 min', '30 min', '45 min', '1 hr', '1.5 hr', '2 hr+']}
                value={profile.exerciseDuration}
                onChange={v => setField('exerciseDuration', v)}
              />
            </div>
          </>
        )}
      </div>
    ),
  },
  {
    id: 'family',
    emoji: '🏠',
    title: 'Home life',
    subtitle: "Things at home shape your schedule more than people admit.",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Kids?</label>
          <SingleChip
            options={['No kids', 'Yes — at school hours', 'Yes — young / at home', 'Yes — grown up']}
            value={profile.kids}
            onChange={v => setField('kids', v)}
          />
        </div>
        {profile.kids !== 'No kids' && profile.kids !== '' && (
          <div>
            <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>School run / pick-up?</label>
            <MultiChip
              options={['Morning drop-off', 'Afternoon pick-up', 'Partner handles it', 'Varies']}
              value={profile.schoolRun}
              onChange={v => setField('schoolRun', v)}
            />
          </div>
        )}
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Commute?</label>
          <SingleChip
            options={['Fully remote', '< 15 min', '15–30 min', '30–60 min', '60+ min', 'Hybrid']}
            value={profile.commute}
            onChange={v => setField('commute', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Partner / housemates?</label>
          <SingleChip
            options={['Live alone', 'Partner (different hours)', 'Partner (same hours)', 'Housemates', 'Family home']}
            value={profile.household}
            onChange={v => setField('household', v)}
          />
        </div>
      </div>
    ),
  },
  {
    id: 'workstyle',
    emoji: '⚡',
    title: 'How you work',
    subtitle: "Your natural rhythm matters for when deep work gets scheduled.",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>I'm sharpest</label>
          <SingleChip
            options={['Early morning', 'Late morning', 'Afternoon', 'Evening', 'Night owl', 'Consistent all day']}
            value={profile.peakTime}
            onChange={v => setField('peakTime', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Breaks during the day</label>
          <SingleChip
            options={['Every hour', 'Every 90 min', 'Every 2+ hrs', 'Only when stuck', 'Rarely take breaks']}
            value={profile.breakFreq}
            onChange={v => setField('breakFreq', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Coffee / tea?</label>
          <SingleChip
            options={['Heavy coffee', 'Moderate coffee', 'Tea person', 'Decaf only', 'Neither']}
            value={profile.caffeine}
            onChange={v => setField('caffeine', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>End of work day</label>
          <TimeChip
            options={['4pm', '5pm', '6pm', '7pm', '8pm', '9pm', 'Flexible']}
            value={profile.workEnd}
            onChange={v => setField('workEnd', v)}
          />
        </div>
      </div>
    ),
  },
  {
    id: 'evening',
    emoji: '🌙',
    title: 'Evening & wind-down',
    subtitle: "A good evening routine protects tomorrow's productivity.",
    isComplete: () => true,
    render: (profile, setField) => (
      <div className="flex flex-col gap-5">
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Evening habits (pick all)</label>
          <MultiChip
            options={['Read', 'Journal', 'Meditate', 'Watch TV / stream', 'Game', 'Social calls', 'Study', 'Side project', 'Gym (evening)', 'Nothing structured']}
            value={profile.eveningHabits}
            onChange={v => setField('eveningHabits', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>I aim to be in bed by</label>
          <TimeChip
            options={['9pm', '10pm', '10:30pm', '11pm', '11:30pm', 'Midnight', 'After midnight']}
            value={profile.bedTime}
            onChange={v => setField('bedTime', v)}
          />
        </div>
        <div>
          <label className="block text-sm mb-2" style={{ color: 'var(--text-secondary)' }}>Anything else I should know about your day?</label>
          <TextInput
            value={profile.freeform}
            onChange={v => setField('freeform', v)}
            placeholder="e.g. I pick up meds at 3pm Tuesdays, I have therapy every other Thursday…"
            small
          />
        </div>
      </div>
    ),
  },
]

/* ── Default profile shape ───────────────────────────────────────────────── */

const DEFAULT_PROFILE = {
  name: '',
  wakeTime: '',
  breakfast: '',
  workStart: '',
  pets: [],
  dogWalkTimes: [],
  dogWalkDuration: '',
  lunchStyle: '',
  lunchTime: '',
  dinnerTime: '',
  dinnerStyle: '',
  exerciseFreq: '',
  exerciseTypes: [],
  exerciseTime: '',
  exerciseDuration: '',
  kids: '',
  schoolRun: [],
  commute: '',
  household: '',
  peakTime: '',
  breakFreq: '',
  caffeine: '',
  workEnd: '',
  eveningHabits: [],
  bedTime: '',
  freeform: '',
}

/* ── Main Onboarding component ───────────────────────────────────────────── */

export default function Onboarding({ onComplete }) {
  const [stepIdx, setStepIdx] = useState(0)
  const [profile, setProfile] = useState(DEFAULT_PROFILE)
  const [saving, setSaving] = useState(false)

  const step = STEPS[stepIdx]
  const isLast = stepIdx === STEPS.length - 1
  const canAdvance = step.isComplete(profile)

  const setField = (key, value) => setProfile(p => ({ ...p, [key]: value }))

  const next = () => {
    if (isLast) {
      handleFinish()
    } else {
      setStepIdx(i => i + 1)
    }
  }

  const back = () => setStepIdx(i => i - 1)

  const handleFinish = async () => {
    setSaving(true)
    try {
      await window.api.profile.save(profile)
      onComplete(profile)
    } finally {
      setSaving(false)
    }
  }

  const handleSkip = async () => {
    setSaving(true)
    try {
      await window.api.profile.save({ ...DEFAULT_PROFILE, skipped: true })
      onComplete(null)
    } finally {
      setSaving(false)
    }
  }

  const progress = ((stepIdx + 1) / STEPS.length) * 100

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center"
      style={{ background: 'rgba(10,22,40,0.98)' }}>
      <div className="w-full max-w-lg mx-4">
        {/* Progress bar */}
        <div className="h-0.5 rounded-full mb-8" style={{ background: 'var(--bg-card)' }}>
          <div
            className="h-0.5 rounded-full transition-all duration-300"
            style={{ width: `${progress}%`, background: 'var(--teal)' }}
          />
        </div>

        {/* Step counter */}
        <div className="text-xs mb-4 font-medium" style={{ color: 'var(--text-disabled)' }}>
          {stepIdx + 1} / {STEPS.length}
        </div>

        {/* Card */}
        <div className="rounded-2xl p-8" style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border)' }}>
          <div className="text-3xl mb-3">{step.emoji}</div>
          <h2 className="text-xl font-bold text-white mb-1">{step.title}</h2>
          <p className="text-sm mb-6" style={{ color: 'var(--text-secondary)' }}>{step.subtitle}</p>

          <div className="mb-8">
            {step.render(profile, setField)}
          </div>

          <div className="flex items-center gap-3">
            {stepIdx > 0 && (
              <button onClick={back}
                className="px-4 py-2.5 rounded-xl text-sm transition-colors"
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border)' }}>
                ← Back
              </button>
            )}
            <button
              onClick={next}
              disabled={!canAdvance || saving}
              className="flex-1 py-3 rounded-xl font-bold text-base transition-all disabled:opacity-40"
              style={{ background: 'var(--teal)', color: '#000', boxShadow: canAdvance ? '0 4px 16px var(--teal-glow)' : 'none' }}
            >
              {saving ? 'Saving…' : isLast ? 'Start DayForge ✓' : 'Next →'}
            </button>
            {stepIdx === 0 && (
              <button onClick={handleSkip} disabled={saving}
                className="px-4 py-2.5 rounded-xl text-sm transition-colors"
                style={{ color: 'var(--text-disabled)' }}>
                Skip
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

import { useState, useEffect } from 'react'
import { todayString, getMondayOfWeek } from '../utils/time'
import { getCategoryColor } from '../utils/colors'

function ProposedBlock({ block, onEdit }) {
  const color = getCategoryColor(block.category)
  return (
    <div
      className="flex items-center gap-3 rounded-lg px-3 py-2 mb-2 cursor-pointer hover:brightness-110 transition-all"
      style={{ background: color.bg, borderLeft: `3px solid ${color.border}` }}
      onClick={() => onEdit && onEdit(block)}
    >
      <div className="flex-shrink-0 text-xs w-20" style={{ color: color.text }}>
        {block.start_time}–{block.end_time}
      </div>
      <div className="flex-1">
        <div className="text-white text-sm font-medium">{block.title}</div>
        {block.notes && <div className="text-xs mt-0.5" style={{ color: 'var(--text-secondary)' }}>{block.notes}</div>}
      </div>
    </div>
  )
}

export default function MorningBriefing({ onDismiss, onApply }) {
  const [step, setStep] = useState('focus') // 'focus' | 'generating' | 'review'
  const [focus, setFocus] = useState('')
  const [greeting, setGreeting] = useState('')
  const [schedule, setSchedule] = useState([])
  const [error, setError] = useState(null)

  const handleGenerate = async () => {
    if (!focus.trim()) return
    setStep('generating')
    setError(null)
    try {
      const monday = getMondayOfWeek(todayString())
      const [tRes, mRes, sRes] = await Promise.all([
        window.api.templates.getAll(),
        window.api.meetings.getForWeek(monday),
        window.api.stats.getLast4Weeks(),
      ])
      const res = await window.api.ai.morningBriefing(
        focus,
        tRes.data,
        mRes.data,
        sRes.data,
      )
      if (res.error) throw new Error(res.error)
      const data = res.data
      setGreeting(data.greeting || `Good morning! Let's make today count.`)
      setSchedule(data.proposed_schedule || [])
      setStep('review')
    } catch (e) {
      setError(e.message)
      setStep('focus')
    }
  }

  const handleStartDay = async () => {
    try {
      // Apply proposed schedule as blocks for today
      const today = todayString()
      for (const block of schedule) {
        await window.api.meetings.create({
          date: today,
          title: block.title,
          start_time: block.start_time,
          end_time: block.end_time,
          description: block.notes || '',   // AI returns 'notes', meetings schema uses 'description'
          color: block.color || '#4CB8CC',
          source: 'morning_brief',
        })
      }
      onApply?.()
      onDismiss()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <div className="fixed inset-0 flex items-center justify-center z-50"
      style={{ background: 'rgba(10,22,40,0.97)' }}>
      <div className="w-full max-w-lg px-8">
        {step === 'focus' && (
          <>
            <h1 className="text-3xl font-bold text-white mb-2">Good morning.</h1>
            <p className="text-lg mb-8" style={{ color: 'var(--text-secondary)' }}>
              What's your main focus today?
            </p>
            <input
              className="w-full rounded-xl px-5 py-4 text-lg outline-none mb-4"
              style={{
                background: 'var(--bg-card)',
                border: '1px solid var(--border-strong)',
                color: 'var(--text-primary)',
              }}
              placeholder="e.g. Finish the auth module and prep tomorrow's content"
              value={focus}
              onChange={e => setFocus(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter') handleGenerate() }}
              autoFocus
              onFocus={e => e.target.style.borderColor = 'var(--teal)'}
              onBlur={e => e.target.style.borderColor = 'var(--border-strong)'}
            />
            {error && <p className="text-sm mb-3" style={{ color: 'var(--error)' }}>{error}</p>}
            <div className="flex gap-3">
              <button onClick={handleGenerate} disabled={!focus.trim()}
                className="flex-1 py-3 rounded-xl font-bold text-base transition-all disabled:opacity-40"
                style={{ background: 'var(--teal)', color: '#000', boxShadow: '0 4px 16px var(--teal-glow)' }}>
                Build my day →
              </button>
              <button onClick={onDismiss}
                className="px-6 py-3 rounded-xl text-base transition-colors"
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border)' }}>
                Skip
              </button>
            </div>
          </>
        )}

        {step === 'generating' && (
          <div className="text-center">
            <div className="text-2xl font-bold text-white mb-4 loading-pulse">Building your day…</div>
            <p style={{ color: 'var(--text-secondary)' }}>Analysing your schedule and focus</p>
          </div>
        )}

        {step === 'review' && (
          <>
            <p className="text-base mb-6" style={{ color: 'var(--teal)' }}>{greeting}</p>
            <div className="max-h-80 overflow-y-auto mb-6 pr-1">
              {schedule.map((block, i) => (
                <ProposedBlock key={i} block={block} />
              ))}
            </div>
            {error && <p className="text-sm mb-3" style={{ color: 'var(--error)' }}>{error}</p>}
            <div className="flex gap-3">
              <button onClick={handleStartDay}
                className="flex-1 py-3 rounded-xl font-bold text-base transition-all"
                style={{ background: 'var(--teal)', color: '#000', boxShadow: '0 4px 16px var(--teal-glow)' }}>
                Start My Day ✓
              </button>
              <button onClick={() => setStep('focus')}
                className="px-5 py-3 rounded-xl text-sm transition-colors"
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border)' }}>
                ← Back
              </button>
              <button onClick={onDismiss}
                className="px-5 py-3 rounded-xl text-sm transition-colors"
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border)' }}>
                Skip
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  )
}

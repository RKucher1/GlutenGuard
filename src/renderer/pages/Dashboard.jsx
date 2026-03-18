import { useState, useEffect } from 'react'
import { getMondayOfWeek, todayString } from '../utils/time'
import { getCategoryColor } from '../utils/colors'

function StatCard({ value, label, accent }) {
  return (
    <div className="rounded-xl p-6" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
      <div className="text-3xl font-bold" style={{ color: accent || 'var(--teal)' }}>{value}</div>
      <div className="text-sm mt-1" style={{ color: 'var(--text-secondary)' }}>{label}</div>
    </div>
  )
}

function CategoryBar({ label, scheduled, completed, accent }) {
  const pct = scheduled > 0 ? Math.round((completed / scheduled) * 100) : 0
  return (
    <div className="mb-4">
      <div className="flex justify-between text-sm mb-1">
        <span style={{ color: 'var(--text-secondary)' }}>{label}</span>
        <span style={{ color: accent }}>{completed}/{scheduled} ({pct}%)</span>
      </div>
      <div className="h-2 rounded-full" style={{ background: 'var(--bg-primary)' }}>
        <div className="h-2 rounded-full transition-all duration-500"
          style={{ width: `${pct}%`, background: accent }} />
      </div>
    </div>
  )
}

function DotGrid({ weeks }) {
  return (
    <div className="flex flex-col gap-2">
      {weeks.map((week, wi) => (
        <div key={wi} className="flex gap-2">
          {week.map((day, di) => {
            let color = 'var(--text-disabled)'
            if (day.pct === null) color = 'var(--bg-card)'
            else if (day.pct >= 0.7) color = 'var(--success)'
            else if (day.pct >= 0.5) color = 'var(--warning)'
            else color = 'var(--error)'
            return (
              <div key={di} title={`${day.date}: ${day.pct !== null ? Math.round(day.pct * 100) + '%' : 'no data'}`}
                className="w-6 h-6 rounded-sm transition-colors"
                style={{ background: color }} />
            )
          })}
        </div>
      ))}
    </div>
  )
}

export default function Dashboard() {
  const today = todayString()
  const monday = getMondayOfWeek(today)
  const [summary, setSummary] = useState(null)
  const [streak, setStreak] = useState(0)
  const [last4, setLast4] = useState([])
  const [bestWeek, setBestWeek] = useState(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    async function load() {
      try {
        const [sRes, stRes, l4Res, bwRes] = await Promise.all([
          window.api.stats.getWeekly(monday),
          window.api.stats.getStreak(),
          window.api.stats.getLast4Weeks(),
          window.api.stats.getBestWeek(),
        ])
        if (cancelled) return
        if (sRes.data) setSummary(sRes.data)
        if (stRes.data) setStreak(stRes.data.streak)
        if (l4Res.data) setLast4(l4Res.data)
        if (bwRes.data) setBestWeek(bwRes.data)
      } finally {
        if (!cancelled) setIsLoading(false)
      }
    }
    load()
    return () => { cancelled = true }
  }, [])

  const catLabels = {
    code: 'Deep Focus',
    content: 'Content',
    upload: 'Upload',
    flex: 'Flex / Admin',
    break: 'Break',
  }

  const totalPct = summary?.total.scheduled > 0
    ? Math.round((summary.total.completed / summary.total.scheduled) * 100)
    : 0

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full" style={{ color: 'var(--text-secondary)' }}>
        <span className="loading-pulse">Loading…</span>
      </div>
    )
  }

  return (
    <div className="p-6 max-w-3xl overflow-y-auto" style={{ background: 'var(--bg-primary)' }}>
      <h1 className="text-xl font-bold text-white mb-6">Dashboard</h1>

      {/* Stats row */}
      <div className="grid grid-cols-4 gap-4 mb-8">
        <StatCard value={`${totalPct}%`} label="This week completion" />
        <StatCard value={summary?.total.completed ?? 0} label="Blocks completed" accent="var(--success)" />
        <StatCard value={`${streak}d`} label="Current streak" accent="var(--gold)" />
        <StatCard
          value={bestWeek ? `${Math.round(bestWeek.pct * 100)}%` : '—'}
          label={bestWeek ? `Best week (${bestWeek.week})` : 'Best week'}
          accent="var(--copper)"
        />
      </div>

      {/* Category breakdown */}
      <div className="rounded-xl p-6 mb-6" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
        <h2 className="text-sm font-semibold mb-4 text-white">This Week — by Category</h2>
        {summary && Object.entries(summary.byCategory).length > 0 ? (
          Object.entries(summary.byCategory).map(([cat, data]) => {
            const color = getCategoryColor(cat)
            return (
              <CategoryBar
                key={cat}
                label={catLabels[cat] || cat}
                scheduled={data.scheduled}
                completed={data.completed}
                accent={color.border}
              />
            )
          })
        ) : (
          <p className="text-sm" style={{ color: 'var(--text-disabled)' }}>No completion data yet. Mark blocks as done to see stats.</p>
        )}
      </div>

      {/* Last 4 weeks grid */}
      <div className="rounded-xl p-6" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
        <h2 className="text-sm font-semibold mb-1 text-white">Last 4 Weeks</h2>
        <p className="text-xs mb-4" style={{ color: 'var(--text-disabled)' }}>Mon–Fri · Green ≥70% · Yellow ≥50% · Red &lt;50%</p>
        {last4.length > 0 ? (
          <DotGrid weeks={last4} />
        ) : (
          <p className="text-sm" style={{ color: 'var(--text-disabled)' }}>No data yet.</p>
        )}
      </div>
    </div>
  )
}

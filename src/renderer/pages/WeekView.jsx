import { useState, useEffect, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { getMondayOfWeek, todayString } from '../utils/time'
import { getCategoryColor } from '../utils/colors'
import AddMeetingModal from '../components/schedule/AddMeetingModal'

const DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']

function addDays(dateStr, n) {
  const d = new Date(dateStr + 'T12:00:00')
  d.setDate(d.getDate() + n)
  return d.toISOString().slice(0, 10)
}

function isMeetingItem(item) {
  return !!item.source || (item.description !== undefined && !item.template_id)
}

function BlockPill({ item, onClick }) {
  const meeting = isMeetingItem(item)
  const isGcal = item.source === 'gcal'
  const color = getCategoryColor(meeting ? 'upload' : item.category)

  return (
    <div
      onClick={() => onClick && onClick(item)}
      style={{
        background: meeting ? '#1A1228' : color.bg,
        borderLeft: `3px solid ${meeting ? '#C87941' : color.border}`,
        border: meeting ? '1px dashed #C87941' : undefined,
        borderLeftStyle: 'solid',
        opacity: isGcal ? 0.85 : 1,
      }}
      className="rounded-r px-2 py-1 mb-1 cursor-pointer relative overflow-hidden hover:brightness-110 transition-all"
      title={`${item.title} ${item.start_time}–${item.end_time}`}
    >
      <div style={{ color: meeting ? '#D4935A' : color.text }} className="text-[10px] font-medium">
        {item.start_time}
      </div>
      <div className="text-white text-xs font-medium truncate leading-tight">{item.title}</div>
      {isGcal && <span className="absolute top-0.5 right-1 text-[10px] opacity-70">🔒</span>}
    </div>
  )
}

export default function WeekView() {
  const navigate = useNavigate()
  const today = todayString()
  const [monday, setMonday] = useState(() => getMondayOfWeek(today))
  const [blocksByDate, setBlocksByDate] = useState({})
  const [meetingsByDate, setMeetingsByDate] = useState({})
  const [isLoading, setIsLoading] = useState(true)
  const [addMeetingDate, setAddMeetingDate] = useState(null)
  const [editMeeting, setEditMeeting] = useState(null)
  const [syncing, setSyncing] = useState(false)
  const [lastSync, setLastSync] = useState(null)

  const weekDates = Array.from({ length: 5 }, (_, i) => addDays(monday, i))

  const loadWeek = useCallback(async () => {
    setIsLoading(true)
    try {
      const [blocksRes, meetingsRes] = await Promise.all([
        window.api.blocks.getByWeek(monday),
        window.api.meetings.getForWeek(monday),
      ])
      const bMap = {}
      const mMap = {}
      weekDates.forEach(d => { bMap[d] = []; mMap[d] = [] })
      if (blocksRes.data) {
        for (const b of blocksRes.data) { if (bMap[b.date]) bMap[b.date].push(b) }
      }
      if (meetingsRes.data) {
        for (const m of meetingsRes.data) { if (mMap[m.date]) mMap[m.date].push(m) }
      }
      setBlocksByDate(bMap)
      setMeetingsByDate(mMap)
    } finally {
      setIsLoading(false)
    }
  }, [monday])

  useEffect(() => { loadWeek() }, [loadWeek])

  const prevWeek = () => setMonday(addDays(monday, -7))
  const nextWeek = () => setMonday(addDays(monday, 7))

  const formatWeekLabel = () => {
    const fri = addDays(monday, 4)
    const m = new Date(monday + 'T12:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    const f = new Date(fri + 'T12:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    return `${m} – ${f}`
  }

  const handleSyncGcal = async () => {
    setSyncing(true)
    try {
      await window.api.gcal.sync(monday)
      setLastSync(new Date().toLocaleTimeString())
      loadWeek()
    } catch (e) {
      alert('GCal sync failed: ' + e.message)
    } finally {
      setSyncing(false)
    }
  }

  return (
    <div className="flex flex-col h-full" style={{ background: 'var(--bg-primary)' }}>
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2 border-b flex-shrink-0"
        style={{ borderColor: 'var(--border)', background: 'var(--bg-secondary)' }}>
        <div className="flex items-center gap-3">
          <button onClick={prevWeek} className="text-gray-400 hover:text-white px-2 py-1 rounded transition-colors text-sm">←</button>
          <span className="text-white text-sm font-medium w-40 text-center">{formatWeekLabel()}</span>
          <button onClick={nextWeek} className="text-gray-400 hover:text-white px-2 py-1 rounded transition-colors text-sm">→</button>
          <button onClick={() => setMonday(getMondayOfWeek(today))}
            className="text-xs px-2 py-1 rounded transition-colors"
            style={{ color: 'var(--teal)', border: '1px solid var(--teal)' }}>
            This Week
          </button>
        </div>
        <div className="flex items-center gap-2">
          {lastSync && <span className="text-xs" style={{ color: 'var(--text-secondary)' }}>Synced {lastSync}</span>}
          <button onClick={handleSyncGcal} disabled={syncing}
            className="text-xs px-3 py-1 rounded transition-colors disabled:opacity-50"
            style={{ color: 'var(--steel)', border: '1px solid var(--steel)' }}>
            {syncing ? 'Syncing…' : '⟳ GCal'}
          </button>
        </div>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center flex-1" style={{ color: 'var(--text-secondary)' }}>
          <span className="loading-pulse">Loading…</span>
        </div>
      ) : (
        <div className="grid grid-cols-5 flex-1 overflow-hidden">
          {weekDates.map((date, i) => {
            const isToday = date === today
            const dayBlocks = blocksByDate[date] || []
            const dayMeetings = meetingsByDate[date] || []
            const d = new Date(date + 'T12:00:00')
            const allItems = [...dayBlocks, ...dayMeetings].sort((a, b) => a.start_time.localeCompare(b.start_time))

            return (
              <div key={date} className="flex flex-col border-r last:border-r-0 overflow-hidden"
                style={{ borderColor: 'var(--border)' }}>
                {/* Column header */}
                <div className="flex items-center justify-between px-2 py-2 border-b flex-shrink-0"
                  style={{ borderColor: 'var(--border)', background: isToday ? 'rgba(76,184,204,0.06)' : 'var(--bg-secondary)' }}>
                  <button onClick={() => navigate('/')}
                    className="text-xs font-semibold hover:opacity-80 transition-opacity"
                    style={{ color: isToday ? 'var(--teal)' : 'var(--text-secondary)' }}>
                    {DAYS[i]} {d.getDate()}
                    {isToday && <span className="ml-1" style={{ color: 'var(--copper)' }}>●</span>}
                  </button>
                  <button onClick={() => setAddMeetingDate(date)}
                    className="text-xs w-5 h-5 flex items-center justify-center rounded transition-colors hover:opacity-100"
                    style={{ color: 'var(--teal)', opacity: 0.6 }} title="Add meeting">
                    +
                  </button>
                </div>

                {/* Items */}
                <div className="flex-1 overflow-y-auto p-1.5">
                  {allItems.length === 0 && (
                    <div className="text-center py-4 text-[10px]" style={{ color: 'var(--text-disabled)' }}>—</div>
                  )}
                  {allItems.map(item => (
                    <BlockPill
                      key={`${item.source !== undefined ? 'm' : 'b'}-${item.id}`}
                      item={item}
                      onClick={item.source !== undefined ? setEditMeeting : undefined}
                    />
                  ))}
                </div>
              </div>
            )
          })}
        </div>
      )}

      {(addMeetingDate || editMeeting) && (
        <AddMeetingModal
          date={addMeetingDate}
          meeting={editMeeting}
          onClose={() => { setAddMeetingDate(null); setEditMeeting(null) }}
          onSaved={() => { setAddMeetingDate(null); setEditMeeting(null); loadWeek() }}
        />
      )}
    </div>
  )
}

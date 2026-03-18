import { useState, useRef, useEffect } from 'react'
import useScheduleStore from '../store/useScheduleStore'
import { todayString, getMondayOfWeek } from '../utils/time'

const MODES = ['Chat', 'Replan Day', 'Plan Week']

function Msg({ role, text, changes, meetings, onApply, applied }) {
  return (
    <div className={`mb-4 ${role === 'user' ? 'text-right' : ''}`}>
      <div
        className="inline-block text-sm rounded-xl px-3 py-2 max-w-[85%] text-left"
        style={{
          background: role === 'user' ? 'var(--teal)' : 'var(--bg-card)',
          color: role === 'user' ? '#000' : 'var(--text-primary)',
        }}
      >
        {text}
      </div>
      {(changes?.length > 0 || meetings?.length > 0) && !applied && (
        <div className="mt-2">
          {changes?.length > 0 && (
            <div className="text-xs mb-1" style={{ color: 'var(--text-secondary)' }}>
              {changes.length} block change{changes.length !== 1 ? 's' : ''} proposed
            </div>
          )}
          {meetings?.length > 0 && (
            <div className="text-xs mb-1" style={{ color: 'var(--text-secondary)' }}>
              {meetings.length} meeting{meetings.length !== 1 ? 's' : ''} to add
            </div>
          )}
          <button
            onClick={onApply}
            className="w-full rounded-lg py-2.5 text-sm font-bold transition-all"
            style={{
              background: 'linear-gradient(135deg, var(--teal) 0%, #3A9BB0 100%)',
              color: '#000',
              boxShadow: '0 4px 16px var(--teal-glow)',
            }}
          >
            Apply Changes
          </button>
        </div>
      )}
      {applied && (
        <div className="text-xs mt-1" style={{ color: 'var(--success)' }}>✓ Applied</div>
      )}
    </div>
  )
}

export default function ChatPanel({ isOpen, onToggle, onApplied }) {
  const [mode, setMode] = useState(0)
  const [input, setInput] = useState('')
  const [weekInput, setWeekInput] = useState('')
  const [history, setHistory] = useState([]) // { role, text, changes, meetings, applied }
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const { blocks, selectedDate } = useScheduleStore()
  const messagesEndRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [history, loading])

  // Listen for open-chat-panel from main (inactivity nudge)
  useEffect(() => {
    if (window.electronAPI?.on) {
      window.electronAPI.on('open-chat-panel', (event, msg) => {
        onToggle(true)
        if (msg) {
          setMode(0)
          setInput(msg)
        }
      })
    }
  }, [onToggle])

  const getContext = async () => {
    const monday = getMondayOfWeek(todayString())
    const [wRes] = await Promise.all([
      window.api.meetings.getForWeek(monday),
    ])
    const completed = blocks.filter(b => b.status === 'done')
    return { schedule: blocks, weekMeetings: wRes.data || [], completed }
  }

  const apply = async (changes, meetings) => {
    try {
      await window.api.ai.applyChanges(changes || [], meetings || [])
      onApplied?.()
      return true
    } catch (e) {
      setError('Apply failed: ' + e.message)
      return false
    }
  }

  const handleSendChat = async () => {
    if (!input.trim()) return
    const userText = input.trim()
    setInput('')
    setError(null)
    setHistory(h => [...h, { role: 'user', text: userText }])
    setLoading(true)

    try {
      const { schedule, weekMeetings, completed } = await getContext()
      const apiHistory = history.filter(m => m.role !== 'system').map(m => ({
        role: m.role,
        content: m.text,
      }))
      const res = await window.api.ai.chat(schedule, weekMeetings, userText, apiHistory, completed)
      const data = res.data
      if (res.error) throw new Error(res.error)
      setHistory(h => [...h, {
        role: 'assistant',
        text: data.message,
        changes: data.proposed_changes,
        meetings: data.proposed_meetings,
        applied: false,
        applyFn: () => apply(data.proposed_changes, data.proposed_meetings),
      }])
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const handleReplanDay = async () => {
    setError(null)
    setLoading(true)
    try {
      const completed = blocks.filter(b => b.status === 'done')
      const currentTime = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false })
      const res = await window.api.ai.replanDay(blocks, currentTime, completed)
      if (res.error) throw new Error(res.error)
      const data = res.data
      setHistory(h => [...h, {
        role: 'assistant',
        text: data.message,
        changes: data.proposed_changes,
        meetings: [],
        applied: false,
        applyFn: () => apply(data.proposed_changes, []),
      }])
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const handlePlanWeek = async () => {
    if (!weekInput.trim()) return
    const req = weekInput.trim()
    setWeekInput('')
    setError(null)
    setLoading(true)
    try {
      const tRes = await window.api.templates.getAll()
      const monday = getMondayOfWeek(todayString())
      const mRes = await window.api.meetings.getForWeek(monday)
      const res = await window.api.ai.planWeek(tRes.data, mRes.data, req)
      if (res.error) throw new Error(res.error)
      const data = res.data
      setHistory(h => [...h, {
        role: 'assistant',
        text: data.message,
        changes: [],
        meetings: data.proposed_meetings,
        applied: false,
        applyFn: () => apply([], data.proposed_meetings),
      }])
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const markApplied = (idx) => {
    setHistory(h => h.map((m, i) => i === idx ? { ...m, applied: true } : m))
  }

  return (
    <>
      {/* Toggle button */}
      <button
        onClick={() => onToggle(!isOpen)}
        className="fixed bottom-8 right-4 w-12 h-12 rounded-full flex items-center justify-center text-xl z-40 transition-all"
        style={{
          background: 'var(--teal)',
          color: '#000',
          boxShadow: '0 4px 16px var(--teal-glow)',
          transform: isOpen ? 'scale(0.9)' : 'scale(1)',
        }}
        title="Toggle AI assistant (Ctrl+/)"
      >
        💬
      </button>

      {/* Panel */}
      <div
        className="fixed top-0 right-0 h-screen flex flex-col z-30 transition-transform duration-[250ms]"
        style={{
          width: '320px',
          background: 'var(--bg-secondary)',
          borderLeft: '1px solid var(--border)',
          transform: isOpen ? 'translateX(0)' : 'translateX(100%)',
          boxShadow: isOpen ? '-8px 0 32px rgba(0,0,0,0.4)' : 'none',
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b flex-shrink-0"
          style={{ borderColor: 'var(--border)' }}>
          <span className="text-sm font-semibold text-white">DayForge AI</span>
          <button onClick={() => onToggle(false)}
            className="text-gray-500 hover:text-white transition-colors text-lg">×</button>
        </div>

        {/* Mode tabs */}
        <div className="flex gap-1 p-2 flex-shrink-0"
          style={{ background: 'var(--bg-secondary)', borderBottom: '1px solid var(--border)' }}>
          {MODES.map((m, i) => (
            <button key={m} onClick={() => setMode(i)}
              className="flex-1 py-1.5 rounded text-xs font-medium transition-all"
              style={{
                background: mode === i ? 'var(--bg-card)' : 'transparent',
                color: mode === i ? 'var(--teal)' : 'var(--text-secondary)',
                boxShadow: mode === i ? '0 0 12px var(--teal-glow)' : 'none',
              }}>
              {m}
            </button>
          ))}
        </div>

        {/* Messages area */}
        <div className="flex-1 overflow-y-auto p-4">
          {history.length === 0 && !loading && (
            <div className="text-xs text-center py-8" style={{ color: 'var(--text-disabled)' }}>
              {mode === 0 && 'Ask anything about your schedule'}
              {mode === 1 && 'Click "Replan My Day" to get an optimized schedule'}
              {mode === 2 && 'Describe what you want to accomplish this week'}
            </div>
          )}
          {history.map((msg, i) => (
            <Msg
              key={i}
              role={msg.role}
              text={msg.text}
              changes={msg.changes}
              meetings={msg.meetings}
              applied={msg.applied}
              onApply={async () => {
                const ok = await msg.applyFn()
                if (ok) markApplied(i)
              }}
            />
          ))}
          {loading && (
            <div className="mb-4">
              <div className="inline-block px-3 py-2 rounded-xl text-sm loading-pulse"
                style={{ background: 'var(--bg-card)', color: 'var(--text-secondary)' }}>
                Thinking…
              </div>
            </div>
          )}
          {error && (
            <div className="text-xs p-2 rounded mb-2" style={{ color: 'var(--error)', background: 'rgba(255,61,61,0.1)' }}>
              {error}
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input area */}
        <div className="p-4 border-t flex-shrink-0" style={{ borderColor: 'var(--border)' }}>
          {mode === 0 && (
            <div className="flex gap-2">
              <input
                ref={inputRef}
                className="flex-1 rounded-lg px-3 py-2 text-sm outline-none"
                style={{ background: 'var(--bg-input)', border: '1px solid var(--border)', color: 'var(--text-primary)' }}
                placeholder="Ask or describe a change…"
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleSendChat() } }}
              />
              <button onClick={handleSendChat} disabled={loading || !input.trim()}
                className="px-3 py-2 rounded-lg text-sm font-semibold transition-colors disabled:opacity-40"
                style={{ background: 'var(--teal)', color: '#000' }}>
                ↑
              </button>
            </div>
          )}
          {mode === 1 && (
            <button onClick={handleReplanDay} disabled={loading}
              className="w-full py-3 rounded-lg text-sm font-bold transition-all disabled:opacity-40"
              style={{
                background: 'linear-gradient(135deg, var(--teal) 0%, #3A9BB0 100%)',
                color: '#000',
                boxShadow: '0 4px 16px var(--teal-glow)',
              }}>
              {loading ? 'Planning…' : 'Replan My Day'}
            </button>
          )}
          {mode === 2 && (
            <div className="flex flex-col gap-2">
              <textarea
                className="rounded-lg px-3 py-2 text-sm outline-none resize-none"
                style={{ background: 'var(--bg-input)', border: '1px solid var(--border)', color: 'var(--text-primary)' }}
                placeholder="What do you want to accomplish this week?"
                rows={3}
                value={weekInput}
                onChange={e => setWeekInput(e.target.value)}
              />
              <button onClick={handlePlanWeek} disabled={loading || !weekInput.trim()}
                className="w-full py-2.5 rounded-lg text-sm font-bold transition-all disabled:opacity-40"
                style={{
                  background: 'linear-gradient(135deg, var(--teal) 0%, #3A9BB0 100%)',
                  color: '#000',
                  boxShadow: '0 4px 16px var(--teal-glow)',
                }}>
                {loading ? 'Planning…' : 'Plan It'}
              </button>
            </div>
          )}
        </div>
      </div>
    </>
  )
}

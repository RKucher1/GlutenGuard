import React, { useState, useEffect, useCallback } from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import DayView from './pages/DayView'
import WeekView from './pages/WeekView'
import Dashboard from './pages/Dashboard'
import Settings from './pages/Settings'
import Sidebar from './components/layout/Sidebar'
import TopBar from './components/layout/TopBar'
import ChatPanel from './components/ChatPanel'
import MorningBriefing from './components/MorningBriefing'
import Onboarding from './components/Onboarding'
import useScheduleStore from './store/useScheduleStore'
import './index.css'

class ErrorBoundary extends React.Component {
  constructor(props) { super(props); this.state = { error: null } }
  static getDerivedStateFromError(error) { return { error } }
  render() {
    if (this.state.error) {
      return (
        <div className="flex flex-col items-center justify-center h-full gap-4 p-8">
          <div className="text-lg font-semibold text-white">Something went wrong</div>
          <div className="text-sm text-red-400 max-w-md text-center">{this.state.error.message}</div>
          <button
            onClick={() => this.setState({ error: null })}
            className="px-4 py-2 rounded-lg text-sm font-medium"
            style={{ background: 'var(--teal)', color: '#000' }}
          >
            Try again
          </button>
        </div>
      )
    }
    return this.props.children
  }
}

function shouldShowMorningBriefing(blocks) {
  const hour = new Date().getHours()
  if (hour >= 12) return false
  const hasCompleted = blocks.some(b => b.status === 'done')
  return !hasCompleted
}

function App() {
  const [chatOpen, setChatOpen] = useState(false)
  const [showBriefing, setShowBriefing] = useState(false)
  const [showOnboarding, setShowOnboarding] = useState(false)
  const { blocks, selectedDate, goNextDay, goPrevDay, setDate } = useScheduleStore()

  // Check first-launch onboarding
  useEffect(() => {
    window.api?.profile?.isComplete().then(res => {
      if (res?.data?.complete === false) setShowOnboarding(true)
    }).catch(() => {})
  }, [])

  // Morning briefing trigger — only after onboarding is done
  useEffect(() => {
    if (!showOnboarding && blocks.length > 0 && shouldShowMorningBriefing(blocks)) {
      setShowBriefing(true)
    }
  }, [blocks, showOnboarding])

  // Record stats when navigating away from a day
  const prevDateRef = React.useRef(selectedDate)
  useEffect(() => {
    const prev = prevDateRef.current
    if (prev !== selectedDate && window.api) {
      window.api.stats.recordDay(prev).catch(() => {})
    }
    prevDateRef.current = selectedDate
  }, [selectedDate])

  // Keyboard shortcuts
  const handleKeyDown = useCallback((e) => {
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return
    if (e.ctrlKey && e.key === 'ArrowLeft') { e.preventDefault(); goPrevDay() }
    if (e.ctrlKey && e.key === 'ArrowRight') { e.preventDefault(); goNextDay() }
    if (e.ctrlKey && e.key === '/') { e.preventDefault(); setChatOpen(o => !o) }
    if (e.key === 'Escape') { setChatOpen(false); setShowBriefing(false) }
  }, [goNextDay, goPrevDay])

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [handleKeyDown])

  return (
    <div className="flex h-screen overflow-hidden" style={{ background: 'var(--bg-primary)', color: 'var(--text-primary)' }}>
      <Sidebar />
      <div className="flex flex-col flex-1 overflow-hidden" style={{ marginRight: chatOpen ? '320px' : '0', transition: 'margin-right 250ms cubic-bezier(0.4,0,0.2,1)' }}>
        <TopBar />
        <main className="flex-1 overflow-y-auto">
          <ErrorBoundary>
            <Routes>
              <Route path="/" element={<DayView />} />
              <Route path="/week" element={<WeekView />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/settings" element={<Settings />} />
            </Routes>
          </ErrorBoundary>
        </main>
      </div>

      <ChatPanel
        isOpen={chatOpen}
        onToggle={setChatOpen}
        onApplied={() => {
          const store = useScheduleStore.getState()
          store.setDate(store.selectedDate)
        }}
      />

      {showOnboarding && (
        <Onboarding
          onComplete={() => setShowOnboarding(false)}
        />
      )}

      {showBriefing && !showOnboarding && (
        <MorningBriefing
          onDismiss={() => setShowBriefing(false)}
          onApply={() => {
            const store = useScheduleStore.getState()
            store.setDate(store.selectedDate)
          }}
        />
      )}
    </div>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
)

import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import DayView from './pages/DayView'
import WeekView from './pages/WeekView'
import Dashboard from './pages/Dashboard'
import Settings from './pages/Settings'
import Sidebar from './components/layout/Sidebar'
import TopBar from './components/layout/TopBar'
import './index.css'

function App() {
  return (
    <div className="flex h-screen bg-[#0A1628] text-white overflow-hidden">
      <Sidebar />
      <div className="flex flex-col flex-1 overflow-hidden">
        <TopBar />
        <main className="flex-1 overflow-y-auto">
          <Routes>
            <Route path="/" element={<DayView />} />
            <Route path="/week" element={<WeekView />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </main>
      </div>
    </div>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
)

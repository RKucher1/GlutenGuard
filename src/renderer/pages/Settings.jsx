import { useState, useEffect } from 'react'

const inputStyle = {
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '6px',
  color: 'var(--text-primary)',
  padding: '8px 12px',
  fontSize: '13px',
  outline: 'none',
}

function ToggleRow({ label, description, value, onChange }) {
  return (
    <div className="flex items-start justify-between py-4 border-b" style={{ borderColor: 'var(--border)' }}>
      <div>
        <div className="text-sm font-medium text-white">{label}</div>
        <div className="text-xs mt-0.5" style={{ color: 'var(--text-secondary)' }}>{description}</div>
      </div>
      <button
        onClick={() => onChange(!value)}
        className="relative flex-shrink-0 w-10 h-5 rounded-full transition-colors duration-200 ml-4"
        style={{ background: value ? 'var(--teal)' : 'var(--bg-card-hover)' }}
      >
        <span
          className="absolute top-0.5 w-4 h-4 rounded-full transition-transform duration-200"
          style={{ background: '#fff', left: value ? '22px' : '2px' }}
        />
      </button>
    </div>
  )
}

export default function Settings() {
  const [settings, setSettings] = useState({
    notifications_enabled: 'true',
    ai_mode: 'cloud',
    inactivity_threshold_mins: '90',
  })
  const [saved, setSaved] = useState(false)
  const [exporting, setExporting] = useState(false)

  useEffect(() => {
    window.api.settings.getAll().then(res => {
      if (res.data) {
        const map = {}
        for (const { key, value } of res.data) map[key] = value
        setSettings(s => ({ ...s, ...map }))
      }
    })
  }, [])

  const saveSetting = async (key, value) => {
    await window.api.settings.set(key, value)
    setSettings(s => ({ ...s, [key]: value }))
    setSaved(true)
    setTimeout(() => setSaved(false), 1500)
  }

  const handleResetTemplates = async () => {
    if (!confirm('Reset all schedule templates to defaults?')) return
    await window.api.templates.reset()
    alert('Templates reset.')
  }

  const handleExport = async () => {
    setExporting(true)
    try {
      // Gather all data and prompt save
      const [blocksRes, templatesRes, meetingsRes, statsRes] = await Promise.all([
        window.api.blocks.getByWeek(new Date().toISOString().slice(0, 10)),
        window.api.templates.getAll(),
        window.api.meetings.getForWeek(new Date().toISOString().slice(0, 10)),
        window.api.stats.getLast4Weeks(),
      ])
      const data = {
        exported_at: new Date().toISOString(),
        blocks: blocksRes.data,
        templates: templatesRes.data,
        meetings: meetingsRes.data,
        stats: statsRes.data,
      }
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `dayforge-export-${new Date().toISOString().slice(0, 10)}.json`
      a.click()
      URL.revokeObjectURL(url)
    } finally {
      setExporting(false)
    }
  }

  return (
    <div className="p-6 max-w-xl overflow-y-auto" style={{ background: 'var(--bg-primary)' }}>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-xl font-bold text-white">Settings</h1>
        {saved && <span className="text-sm" style={{ color: 'var(--success)' }}>✓ Saved</span>}
      </div>

      {/* Notifications */}
      <div className="rounded-xl p-6 mb-4" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
        <h2 className="text-sm font-semibold text-white mb-2">Notifications</h2>

        <ToggleRow
          label="Block transition notifications"
          description="Notify 2 min before each block starts and when it ends"
          value={settings.notifications_enabled === 'true'}
          onChange={v => saveSetting('notifications_enabled', v ? 'true' : 'false')}
        />

        <div className="flex items-center justify-between py-4">
          <div>
            <div className="text-sm font-medium text-white">Inactivity threshold</div>
            <div className="text-xs mt-0.5" style={{ color: 'var(--text-secondary)' }}>Minutes before showing a replan nudge</div>
          </div>
          <input
            type="number"
            style={{ ...inputStyle, width: '80px', textAlign: 'right' }}
            value={settings.inactivity_threshold_mins}
            onChange={e => saveSetting('inactivity_threshold_mins', e.target.value)}
            min={15}
            max={240}
          />
        </div>
      </div>

      {/* AI */}
      <div className="rounded-xl p-6 mb-4" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
        <h2 className="text-sm font-semibold text-white mb-2">AI</h2>
        <div className="flex items-center justify-between py-4">
          <div>
            <div className="text-sm font-medium text-white">AI mode</div>
            <div className="text-xs mt-0.5" style={{ color: 'var(--text-secondary)' }}>cloud = Anthropic API · local = Ollama (privacy mode)</div>
          </div>
          <select
            style={{ ...inputStyle, cursor: 'pointer' }}
            value={settings.ai_mode}
            onChange={e => saveSetting('ai_mode', e.target.value)}
          >
            <option value="cloud">Cloud (Haiku)</option>
            <option value="local">Local (Ollama)</option>
          </select>
        </div>
      </div>

      {/* Data */}
      <div className="rounded-xl p-6" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)' }}>
        <h2 className="text-sm font-semibold text-white mb-4">Data</h2>
        <div className="flex flex-col gap-3">
          <button onClick={handleExport} disabled={exporting}
            className="w-full py-2.5 rounded-lg text-sm font-medium transition-colors disabled:opacity-50"
            style={{ background: 'transparent', color: 'var(--teal)', border: '1px solid var(--border-strong)' }}>
            {exporting ? 'Exporting…' : '↓ Export my data (JSON)'}
          </button>
          <button onClick={handleResetTemplates}
            className="w-full py-2.5 rounded-lg text-sm transition-colors"
            style={{ background: 'transparent', color: 'var(--error)', border: '1px solid rgba(255,61,61,0.3)' }}>
            Reset schedule templates to defaults
          </button>
        </div>
      </div>
    </div>
  )
}

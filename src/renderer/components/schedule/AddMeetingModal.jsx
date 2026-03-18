import { useState } from 'react'

const inputStyle = {
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '6px',
  color: 'var(--text-primary)',
  padding: '10px 14px',
  fontSize: '14px',
  width: '100%',
  outline: 'none',
  transition: 'border-color 150ms ease',
}

export default function AddMeetingModal({ date, meeting, onClose, onSaved }) {
  const isEdit = !!meeting
  const [form, setForm] = useState({
    title: meeting?.title || '',
    date: meeting?.date || date || '',
    start_time: meeting?.start_time || '',
    end_time: meeting?.end_time || '',
    description: meeting?.description || '',
  })
  const [conflicts, setConflicts] = useState(null)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  const handleSubmit = async (forceAdd = false) => {
    if (!form.title.trim() || !form.date || !form.start_time || !form.end_time) {
      setError('Title, date, start and end time are required.')
      return
    }
    setSaving(true)
    setError(null)

    try {
      if (!forceAdd) {
        const res = await window.api.meetings.checkConflicts(form, form.date)
        if (res.data?.hasConflict) {
          setConflicts(res.data.conflicts)
          setSaving(false)
          return
        }
      }

      if (isEdit) {
        await window.api.meetings.update(meeting.id, {
          title: form.title,
          start_time: form.start_time,
          end_time: form.end_time,
          description: form.description,
        })
      } else {
        await window.api.meetings.create(form)
      }
      onSaved()
    } catch (e) {
      setError(e.message)
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!confirm('Delete this meeting?')) return
    try {
      await window.api.meetings.delete(meeting.id)
      onSaved()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <div className="fixed inset-0 flex items-center justify-center z-50"
      style={{ background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(4px)' }}
      onClick={onClose}>
      <div className="rounded-xl p-8 w-[440px] shadow-2xl"
        style={{ background: 'var(--bg-secondary)', border: '1px solid var(--border-strong)', minWidth: '400px' }}
        onClick={e => e.stopPropagation()}>
        <h2 className="text-white text-lg font-semibold mb-6">{isEdit ? 'Edit Meeting' : 'Add Meeting'}</h2>

        <div className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-medium mb-1" style={{ color: 'var(--text-secondary)' }}>Title</label>
            <input
              style={inputStyle}
              value={form.title}
              onChange={e => set('title', e.target.value)}
              placeholder="Meeting title"
              autoFocus
              onFocus={e => e.target.style.borderColor = 'var(--teal)'}
              onBlur={e => e.target.style.borderColor = 'var(--border)'}
            />
          </div>

          <div>
            <label className="block text-xs font-medium mb-1" style={{ color: 'var(--text-secondary)' }}>Date</label>
            <input
              type="date"
              style={{ ...inputStyle, colorScheme: 'dark' }}
              value={form.date}
              onChange={e => set('date', e.target.value)}
              onFocus={e => e.target.style.borderColor = 'var(--teal)'}
              onBlur={e => e.target.style.borderColor = 'var(--border)'}
            />
          </div>

          <div className="flex gap-3">
            <div className="flex-1">
              <label className="block text-xs font-medium mb-1" style={{ color: 'var(--text-secondary)' }}>Start</label>
              <input
                type="time"
                style={{ ...inputStyle, colorScheme: 'dark' }}
                value={form.start_time}
                onChange={e => set('start_time', e.target.value)}
                onFocus={e => e.target.style.borderColor = 'var(--teal)'}
                onBlur={e => e.target.style.borderColor = 'var(--border)'}
              />
            </div>
            <div className="flex-1">
              <label className="block text-xs font-medium mb-1" style={{ color: 'var(--text-secondary)' }}>End</label>
              <input
                type="time"
                style={{ ...inputStyle, colorScheme: 'dark' }}
                value={form.end_time}
                onChange={e => set('end_time', e.target.value)}
                onFocus={e => e.target.style.borderColor = 'var(--teal)'}
                onBlur={e => e.target.style.borderColor = 'var(--border)'}
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium mb-1" style={{ color: 'var(--text-secondary)' }}>Description <span style={{ color: 'var(--text-disabled)' }}>(optional)</span></label>
            <textarea
              style={{ ...inputStyle, resize: 'none' }}
              rows={2}
              value={form.description}
              onChange={e => set('description', e.target.value)}
              placeholder="Notes…"
              onFocus={e => e.target.style.borderColor = 'var(--teal)'}
              onBlur={e => e.target.style.borderColor = 'var(--border)'}
            />
          </div>
        </div>

        {/* Conflict warning */}
        {conflicts && (
          <div className="mt-4 p-3 rounded-lg" style={{ background: 'rgba(200,121,65,0.15)', border: '1px solid var(--copper)' }}>
            <p className="text-sm font-medium mb-2" style={{ color: 'var(--copper)' }}>⚠ Schedule conflict</p>
            <ul className="text-xs mb-3" style={{ color: 'var(--text-secondary)' }}>
              {conflicts.map((c, i) => (
                <li key={i}>• {c.title} ({c.start_time}–{c.end_time})</li>
              ))}
            </ul>
            <div className="flex gap-2">
              <button onClick={() => handleSubmit(true)} disabled={saving}
                className="flex-1 py-2 rounded text-sm font-semibold transition-colors"
                style={{ background: 'var(--copper)', color: '#000' }}>
                Add anyway
              </button>
              <button onClick={() => setConflicts(null)}
                className="flex-1 py-2 rounded text-sm transition-colors"
                style={{ color: 'var(--text-secondary)', border: '1px solid var(--border)' }}>
                Cancel
              </button>
            </div>
          </div>
        )}

        {error && <p className="mt-3 text-sm" style={{ color: 'var(--error)' }}>{error}</p>}

        {!conflicts && (
          <div className="flex gap-2 justify-end mt-6">
            {isEdit && meeting.source !== 'gcal' && (
              <button onClick={handleDelete}
                className="px-4 py-2 text-sm rounded-lg transition-colors"
                style={{ color: 'var(--error)', border: '1px solid rgba(255,61,61,0.3)' }}>
                Delete
              </button>
            )}
            <button onClick={onClose}
              className="px-4 py-2 text-sm transition-colors"
              style={{ color: 'var(--text-secondary)' }}>
              Cancel
            </button>
            {(!isEdit || meeting.source !== 'gcal') && (
              <button onClick={() => handleSubmit(false)} disabled={saving}
                className="px-5 py-2 text-sm rounded-lg font-semibold transition-colors disabled:opacity-50"
                style={{ background: 'var(--teal)', color: '#000' }}>
                {saving ? 'Saving…' : isEdit ? 'Update' : 'Add Meeting'}
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

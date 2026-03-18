import { useState } from 'react'
import { getCategoryColor } from '../../utils/colors'
import useScheduleStore from '../../store/useScheduleStore'

export default function BlockModal({ block, onClose }) {
  const { setBlockStatus } = useScheduleStore()
  const [selectedStatus, setSelectedStatus] = useState(block?.status || 'pending')
  const [note, setNote] = useState(block?.completion_note || '')

  if (!block) return null

  const color = getCategoryColor(block.category)

  const handleStatusClick = async (status) => {
    setSelectedStatus(status)
    if (status === 'done') {
      await setBlockStatus(block.id, status, '')
      onClose()
    }
  }

  const handleSave = async () => {
    await setBlockStatus(block.id, selectedStatus, note)
    onClose()
  }

  const statusButtons = [
    { key: 'done',    label: 'Done' },
    { key: 'partial', label: 'Partial' },
    { key: 'skipped', label: 'Skipped' },
  ]

  return (
    <div
      className="fixed inset-0 bg-black/60 flex items-center justify-center z-50"
      onClick={onClose}
    >
      <div
        className="bg-[#112244] rounded-xl p-6 w-96 shadow-xl"
        onClick={e => e.stopPropagation()}
      >
        <h2 className="text-white text-lg font-semibold mb-1">{block.title}</h2>
        <p className="text-gray-400 text-sm mb-4">{block.start_time} – {block.end_time}</p>

        <div
          className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium mb-5"
          style={{ background: color.bg, color: color.text, border: `1px solid ${color.border}` }}
        >
          {color.label}
        </div>

        <div className="flex gap-2 mb-4">
          {statusButtons.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => handleStatusClick(key)}
              className="flex-1 py-2 rounded-lg text-sm font-medium transition-all"
              style={
                selectedStatus === key
                  ? { background: color.bg, border: `2px solid ${color.border}`, color: color.text }
                  : { background: '#0d1f3c', border: '2px solid #1a3a6b', color: '#9ca3af' }
              }
            >
              {label}
            </button>
          ))}
        </div>

        {(selectedStatus === 'partial' || selectedStatus === 'skipped') && (
          <textarea
            className="w-full bg-[#0d1f3c] text-white text-sm rounded-lg p-3 border border-[#1a3a6b] resize-none mb-4 focus:outline-none focus:border-[#00E5FF]"
            rows={3}
            placeholder={selectedStatus === 'partial' ? 'What happened?' : 'Why was this skipped?'}
            value={note}
            onChange={e => setNote(e.target.value)}
          />
        )}

        <div className="flex gap-2 justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-gray-400 hover:text-white transition-colors"
          >
            Cancel
          </button>
          {selectedStatus !== 'done' && (
            <button
              onClick={handleSave}
              className="px-4 py-2 text-sm rounded-lg font-medium transition-colors"
              style={{ background: color.border, color: '#fff' }}
            >
              Save
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

import useScheduleStore from '../../store/useScheduleStore'
import { formatDisplayDate } from '../../utils/time'

export default function TopBar() {
  const { selectedDate, goNextDay, goPrevDay, loadToday } = useScheduleStore()

  const dayName = new Date(selectedDate + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'long' })

  return (
    <div className="flex items-center justify-between px-4 h-12 bg-[#0d1f3c] border-b border-[#1a3a6b] flex-shrink-0">
      <div className="text-sm text-gray-400 w-48">
        {formatDisplayDate(selectedDate)}
      </div>

      <div className="flex items-center gap-3">
        <button
          onClick={goPrevDay}
          className="text-gray-400 hover:text-white transition-colors px-2 py-1 rounded"
          aria-label="Previous day"
        >
          ←
        </button>
        <span className="text-white text-sm font-medium w-24 text-center">{dayName}</span>
        <button
          onClick={goNextDay}
          className="text-gray-400 hover:text-white transition-colors px-2 py-1 rounded"
          aria-label="Next day"
        >
          →
        </button>
      </div>

      <div className="w-48 flex justify-end">
        <button
          onClick={loadToday}
          className="text-xs text-[#00E5FF] hover:text-[#33ecff] border border-[#00E5FF] px-3 py-1 rounded transition-colors"
        >
          Today
        </button>
      </div>
    </div>
  )
}

import { getCategoryColor, STATUS_STYLES } from '../../utils/colors'
import { timeToPercent, durationMinutes } from '../../utils/time'

export default function TimelineBlock({ block, onEdit }) {
  const color = getCategoryColor(block.category)
  const statusStyle = STATUS_STYLES[block.status] || STATUS_STYLES.pending
  const duration = durationMinutes(block.start_time, block.end_time)

  const top = timeToPercent(block.start_time) + '%'
  const height = (duration / 720 * 100) + '%'

  return (
    <div
      onClick={() => onEdit(block)}
      style={{
        position: 'absolute',
        top,
        height,
        left: '4px',
        right: '4px',
        background: color.bg,
        borderLeft: `3px solid ${color.border}`,
        opacity: statusStyle.opacity,
      }}
      className="rounded-r-md px-3 py-2 cursor-pointer overflow-hidden hover:brightness-110 transition-all"
    >
      {duration > 30 && (
        <>
          <div style={{ color: color.text }} className="text-xs font-medium mb-0.5">
            {color.label}
          </div>
          <div className="text-white font-medium text-sm leading-tight truncate">
            {block.title}
          </div>
          <div className="text-gray-400 text-xs mt-0.5">
            {block.start_time} – {block.end_time}
          </div>
        </>
      )}
      {duration <= 30 && (
        <div className="text-white text-xs truncate">{block.title}</div>
      )}
      {statusStyle.icon && (
        <div
          style={{ color: color.text }}
          className="absolute top-1 right-2 text-sm font-bold"
        >
          {statusStyle.icon}
        </div>
      )}
    </div>
  )
}

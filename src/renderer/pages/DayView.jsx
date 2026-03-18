import { useState } from 'react'
import useBlocks from '../hooks/useBlocks'
import TimelineBlock from '../components/schedule/TimelineBlock'
import BlockModal from '../components/schedule/BlockModal'
import { timeToPercent } from '../utils/time'

const HOURS = Array.from({ length: 13 }, (_, i) => {
  const h = 9 + i
  return { label: h <= 12 ? `${h}am` : h === 12 ? '12pm' : `${h - 12}pm`, value: `${String(h).padStart(2, '0')}:00` }
})

export default function DayView() {
  const { blocks, isLoading, error } = useBlocks()
  const [selectedBlock, setSelectedBlock] = useState(null)

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full text-gray-400">
        Loading...
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-full text-red-400">
        {error}
      </div>
    )
  }

  if (blocks.length === 0) {
    return (
      <div className="flex items-center justify-center h-full text-gray-500">
        No blocks for this day
      </div>
    )
  }

  return (
    <div className="flex h-full p-4 gap-2">
      {/* Hour labels */}
      <div className="w-12 flex-shrink-0 relative" style={{ height: '720px' }}>
        {HOURS.map(({ label, value }) => (
          <div
            key={value}
            className="absolute text-xs text-gray-500 text-right w-full pr-1"
            style={{ top: timeToPercent(value) + '%', transform: 'translateY(-50%)' }}
          >
            {label}
          </div>
        ))}
      </div>

      {/* Timeline canvas */}
      <div className="flex-1 relative" style={{ height: '720px' }}>
        {/* Grid lines */}
        {HOURS.map(({ value }) => (
          <div
            key={value}
            className="absolute w-full border-t border-[#1A2F4A]"
            style={{ top: timeToPercent(value) + '%' }}
          />
        ))}

        {/* Blocks */}
        {blocks.map(block => (
          <TimelineBlock
            key={block.id}
            block={block}
            onEdit={setSelectedBlock}
          />
        ))}
      </div>

      {/* Modal */}
      {selectedBlock && (
        <BlockModal
          block={selectedBlock}
          onClose={() => setSelectedBlock(null)}
        />
      )}
    </div>
  )
}

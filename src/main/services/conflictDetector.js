function timeToMinutes(timeStr) {
  const [h, m] = timeStr.split(':').map(Number)
  return h * 60 + m
}

function detectConflicts(proposed, existingBlocks, existingMeetings) {
  const pStart = timeToMinutes(proposed.start_time)
  const pEnd = timeToMinutes(proposed.end_time)
  const conflicts = []

  const all = [...(existingBlocks || []), ...(existingMeetings || [])]
  for (const item of all) {
    const iStart = timeToMinutes(item.start_time)
    const iEnd = timeToMinutes(item.end_time)
    if (pStart < iEnd && pEnd > iStart) {
      conflicts.push({ title: item.title, start_time: item.start_time, end_time: item.end_time })
    }
  }

  return { hasConflict: conflicts.length > 0, conflicts }
}

module.exports = { detectConflicts }

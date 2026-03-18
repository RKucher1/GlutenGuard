const { getByDate } = require('../db/blocks')

function generateWeek(mondayDate) {
  const monday = new Date(mondayDate + 'T12:00:00')
  for (let i = 0; i < 5; i++) {
    const d = new Date(monday)
    d.setDate(d.getDate() + i)
    const dateStr = d.toISOString().slice(0, 10)
    getByDate(dateStr)
  }
  return { generated: 5 }
}

function detectConflicts(blocks, meetings) {
  const conflicts = []
  for (const meeting of meetings) {
    for (const block of blocks) {
      if (meeting.start_time < block.end_time && meeting.end_time > block.start_time) {
        const overlapStart = Math.max(
          timeToMinutes(meeting.start_time),
          timeToMinutes(block.start_time)
        )
        const overlapEnd = Math.min(
          timeToMinutes(meeting.end_time),
          timeToMinutes(block.end_time)
        )
        conflicts.push({
          blockId: block.id,
          meetingId: meeting.id,
          overlapMinutes: overlapEnd - overlapStart,
        })
      }
    }
  }
  return conflicts
}

function timeToMinutes(timeStr) {
  const [h, m] = timeStr.split(':').map(Number)
  return h * 60 + m
}

module.exports = { generateWeek, detectConflicts }

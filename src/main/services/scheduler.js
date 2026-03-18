const { getByDate } = require('../db/blocks')

function generateWeek(mondayDate) {
  const monday = new Date(mondayDate + 'T12:00:00')
  const dates = []
  for (let i = 0; i < 5; i++) {
    const d = new Date(monday)
    d.setDate(d.getDate() + i)
    const dateStr = d.toISOString().slice(0, 10)
    getByDate(dateStr)
    dates.push(dateStr)
  }
  return { generated: 5, dates }
}

module.exports = { generateWeek }

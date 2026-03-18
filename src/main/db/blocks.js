const db = require('./database')
const { getByDay } = require('./templates')

const VALID_STATUSES = ['pending', 'done', 'partial', 'skipped']

function getByDate(date) {
  let rows = db.prepare('SELECT * FROM daily_blocks WHERE date = ? ORDER BY start_time').all(date)
  if (rows.length === 0) {
    generateFromTemplate(date)
    rows = db.prepare('SELECT * FROM daily_blocks WHERE date = ? ORDER BY start_time').all(date)
  }
  return rows
}

function generateFromTemplate(date) {
  const d = new Date(date + 'T12:00:00')
  const dayName = d.toLocaleDateString('en-US', { weekday: 'short' }).toLowerCase().slice(0, 3)

  if (dayName === 'sat' || dayName === 'sun') {
    return []
  }

  const templates = getByDay(dayName)
  if (templates.length === 0) return []

  const insert = db.prepare(`
    INSERT INTO daily_blocks (date, template_id, start_time, end_time, category, title, status)
    VALUES (@date, @template_id, @start_time, @end_time, @category, @title, 'pending')
  `)

  const insertMany = db.transaction((rows) => {
    for (const row of rows) {
      insert.run(row)
    }
  })

  const rows = templates.map(t => ({
    date,
    template_id: t.id,
    start_time: t.start_time,
    end_time: t.end_time,
    category: t.category,
    title: t.title,
  }))

  insertMany(rows)
}

function updateStatus(id, status, note) {
  if (!VALID_STATUSES.includes(status)) {
    throw new Error('Invalid status: ' + status)
  }
  db.prepare('UPDATE daily_blocks SET status = ?, completion_note = ? WHERE id = ?').run(status, note || null, id)
}

function update(id, fields) {
  const allowed = ['title', 'start_time', 'end_time', 'category']
  const keys = Object.keys(fields).filter(k => allowed.includes(k))
  if (keys.length === 0) return
  const set = keys.map(k => `${k} = @${k}`).join(', ')
  db.prepare(`UPDATE daily_blocks SET ${set} WHERE id = @id`).run({ ...fields, id })
}

function getByWeek(mondayDate) {
  const monday = new Date(mondayDate + 'T12:00:00')
  const result = []
  for (let i = 0; i < 5; i++) {
    const d = new Date(monday)
    d.setDate(d.getDate() + i)
    const dateStr = d.toISOString().slice(0, 10)
    const blocks = getByDate(dateStr)
    result.push(...blocks)
  }
  return result
}

module.exports = { getByDate, generateFromTemplate, updateStatus, update, getByWeek }

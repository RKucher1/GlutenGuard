const db = require('./database')

function getForDate(date) {
  return db.prepare('SELECT * FROM meetings WHERE date = ? ORDER BY start_time').all(date)
}

function getForWeek(mondayDate) {
  const monday = new Date(mondayDate + 'T12:00:00')
  const dates = []
  for (let i = 0; i < 5; i++) {
    const d = new Date(monday)
    d.setDate(d.getDate() + i)
    dates.push(d.toISOString().slice(0, 10))
  }
  const placeholders = dates.map(() => '?').join(',')
  return db.prepare(`SELECT * FROM meetings WHERE date IN (${placeholders}) ORDER BY date, start_time`).all(...dates)
}

function create(meeting) {
  const result = db.prepare(`
    INSERT INTO meetings (date, title, start_time, end_time, description, color, source, gcal_event_id)
    VALUES (@date, @title, @start_time, @end_time, @description, @color, @source, @gcal_event_id)
  `).run({
    date: meeting.date,
    title: meeting.title,
    start_time: meeting.start_time,
    end_time: meeting.end_time,
    description: meeting.description || '',
    color: meeting.color || '#4CB8CC',
    source: meeting.source || 'local',
    gcal_event_id: meeting.gcal_event_id || null,
  })
  return result.lastInsertRowid
}

function update(id, fields) {
  const allowed = ['title', 'start_time', 'end_time', 'description', 'color']
  const keys = Object.keys(fields).filter(k => allowed.includes(k))
  if (keys.length === 0) return
  const set = keys.map(k => `${k} = @${k}`).join(', ')
  db.prepare(`UPDATE meetings SET ${set} WHERE id = @id`).run({ ...fields, id })
}

function remove(id) {
  db.prepare('DELETE FROM meetings WHERE id = ?').run(id)
}

function upsertGcal(meeting) {
  db.prepare(`
    INSERT INTO meetings (date, title, start_time, end_time, description, color, source, gcal_event_id)
    VALUES (@date, @title, @start_time, @end_time, @description, @color, 'gcal', @gcal_event_id)
    ON CONFLICT(gcal_event_id) DO UPDATE SET
      title = excluded.title,
      start_time = excluded.start_time,
      end_time = excluded.end_time,
      description = excluded.description
  `).run(meeting)
}

module.exports = { getForDate, getForWeek, create, update, remove, upsertGcal }

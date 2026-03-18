const db = require('./database')
const { seedTemplates } = require('./seed')

function getAll() {
  return db.prepare('SELECT * FROM schedule_templates ORDER BY day_of_week, start_time').all()
}

function getByDay(day) {
  return db.prepare('SELECT * FROM schedule_templates WHERE day_of_week = ?').all(day)
}

function insert(row) {
  const result = db.prepare(`
    INSERT INTO schedule_templates (day_of_week, start_time, end_time, category, title, notes)
    VALUES (@day_of_week, @start_time, @end_time, @category, @title, @notes)
  `).run(row)
  return result.lastInsertRowid
}

function update(id, fields) {
  const allowed = ['title', 'start_time', 'end_time', 'category', 'notes']
  const keys = Object.keys(fields).filter(k => allowed.includes(k))
  if (keys.length === 0) return
  const set = keys.map(k => `${k} = @${k}`).join(', ')
  db.prepare(`UPDATE schedule_templates SET ${set} WHERE id = @id`).run({ ...fields, id })
}

function remove(id) {
  db.prepare('DELETE FROM schedule_templates WHERE id = ?').run(id)
}

function reset() {
  db.prepare('DELETE FROM schedule_templates').run()
  seedTemplates(db)
}

module.exports = { getAll, getByDay, insert, update, remove, reset }

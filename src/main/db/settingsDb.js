const db = require('./database')

function get(key) {
  const row = db.prepare('SELECT value FROM settings WHERE key = ?').get(key)
  return row ? row.value : null
}

function set(key, value) {
  db.prepare('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)').run(key, String(value))
}

function getAll() {
  return db.prepare('SELECT key, value FROM settings').all()
}

module.exports = { get, set, getAll }

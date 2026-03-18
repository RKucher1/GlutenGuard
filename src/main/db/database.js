const Database = require('better-sqlite3')
const path = require('path')
const { app } = require('electron')
const { seedTemplates } = require('./seed')

const dbPath = path.join(app.getPath('appData'), 'DayForge', 'dayforge.db')

const db = new Database(dbPath, { verbose: null })

db.pragma('journal_mode=WAL')
db.pragma('foreign_keys=ON')

db.exec(`
  CREATE TABLE IF NOT EXISTS schedule_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    day_of_week TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    notes TEXT
  );

  CREATE TABLE IF NOT EXISTS daily_blocks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    template_id INTEGER,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    completion_note TEXT,
    gcal_event_id TEXT,
    FOREIGN KEY (template_id) REFERENCES schedule_templates(id)
  );

  CREATE TABLE IF NOT EXISTS meetings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    title TEXT NOT NULL,
    source TEXT NOT NULL DEFAULT 'manual',
    gcal_event_id TEXT
  );

  CREATE TABLE IF NOT EXISTS ai_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL,
    context_date TEXT,
    messages TEXT NOT NULL DEFAULT '[]',
    applied_changes TEXT NOT NULL DEFAULT '[]'
  );
`)

const count = db.prepare('SELECT COUNT(*) as count FROM schedule_templates').get()
if (count.count === 0) {
  seedTemplates(db)
}

module.exports = db

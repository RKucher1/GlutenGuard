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
    title TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    description TEXT DEFAULT '',
    color TEXT DEFAULT '#4CB8CC',
    source TEXT DEFAULT 'local',
    gcal_event_id TEXT UNIQUE,
    created_at TEXT DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS ai_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL,
    context_date TEXT,
    messages TEXT NOT NULL DEFAULT '[]',
    applied_changes TEXT NOT NULL DEFAULT '[]'
  );

  CREATE TABLE IF NOT EXISTS completion_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    category TEXT NOT NULL,
    blocks_scheduled INTEGER DEFAULT 0,
    blocks_completed INTEGER DEFAULT 0,
    UNIQUE(date, category)
  );

  CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS learning_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,
    block_category TEXT,
    block_title TEXT,
    scheduled_start TEXT,
    scheduled_end TEXT,
    actual_start TEXT,
    actual_end TEXT,
    scheduled_duration_mins INTEGER,
    actual_duration_mins INTEGER,
    day_of_week TEXT,
    hour_of_day INTEGER,
    ai_suggestion_type TEXT,
    applied INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
  );
`)

const count = db.prepare('SELECT COUNT(*) as count FROM schedule_templates').get()
if (count.count === 0) {
  seedTemplates(db)
}

const settingsCount = db.prepare('SELECT COUNT(*) as count FROM settings').get()
if (settingsCount.count === 0) {
  const insertSetting = db.prepare('INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)')
  insertSetting.run('notifications_enabled', 'true')
  insertSetting.run('ai_mode', 'cloud')
  insertSetting.run('theme', 'dark')
  insertSetting.run('inactivity_threshold_mins', '90')
}

module.exports = db

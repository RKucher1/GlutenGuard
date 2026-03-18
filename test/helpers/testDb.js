'use strict'
/**
 * Test DB helper — creates an in-memory SQLite database and injects it into
 * Node's require cache so DB modules never touch the real file or Electron.
 *
 * Usage:
 *   const { setup, teardown } = require('./helpers/testDb')
 *   let mods
 *   before(() => { mods = setup() })   // returns { blocks, meetings, ... }
 *   after(() => teardown())
 */
const Database = require('better-sqlite3')
const path = require('path')

const DB_MODULE_PATH = require.resolve('../../src/main/db/database')
const MAIN_DB_DIR = path.resolve(__dirname, '../../src/main/db')
const MAIN_SVC_DIR = path.resolve(__dirname, '../../src/main/services')

const SCHEMA = `
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
`

function createTestDb() {
  const db = new Database(':memory:')
  db.pragma('journal_mode=WAL')
  db.pragma('foreign_keys=ON')
  db.exec(SCHEMA)
  // Seed templates (no electron dependency)
  const { seedTemplates } = require('../../src/main/db/seed')
  seedTemplates(db)
  // Seed default settings
  const ins = db.prepare('INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)')
  ins.run('notifications_enabled', 'true')
  ins.run('ai_mode', 'cloud')
  ins.run('theme', 'dark')
  ins.run('inactivity_threshold_mins', '90')
  return db
}

function clearRelatedCache() {
  for (const key of Object.keys(require.cache)) {
    if (key.startsWith(MAIN_DB_DIR) || key.startsWith(MAIN_SVC_DIR)) {
      delete require.cache[key]
    }
  }
}

/**
 * Call before each test suite.
 * Returns the loaded DB module accessors so tests can use them.
 */
function setup() {
  clearRelatedCache()
  const db = createTestDb()
  // Inject as if `require('./database')` was already resolved
  require.cache[DB_MODULE_PATH] = {
    id: DB_MODULE_PATH,
    filename: DB_MODULE_PATH,
    loaded: true,
    exports: db,
  }
  // Now safely require all DB / service modules
  const blocks = require('../../src/main/db/blocks')
  const meetings = require('../../src/main/db/meetings')
  const completionStats = require('../../src/main/db/completionStats')
  const settingsDb = require('../../src/main/db/settingsDb')
  const userProfile = require('../../src/main/db/userProfile')
  const learningService = require('../../src/main/services/learningService')
  return { db, blocks, meetings, completionStats, settingsDb, userProfile, learningService }
}

/** Call after each test suite to fully reset state. */
function teardown() {
  clearRelatedCache()
}

module.exports = { setup, teardown, createTestDb, clearRelatedCache }

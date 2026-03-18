const db = require('./database')

function recordDayStats(date) {
  const blocks = db.prepare(`
    SELECT category,
           COUNT(*) as scheduled,
           SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) as completed
    FROM daily_blocks WHERE date = ?
    GROUP BY category
  `).all(date)

  const upsert = db.prepare(`
    INSERT INTO completion_stats (date, category, blocks_scheduled, blocks_completed)
    VALUES (@date, @category, @scheduled, @completed)
    ON CONFLICT(date, category) DO UPDATE SET
      blocks_scheduled = excluded.blocks_scheduled,
      blocks_completed = excluded.blocks_completed
  `)

  const upsertMany = db.transaction((rows) => {
    for (const row of rows) upsert.run(row)
  })

  upsertMany(blocks.map(b => ({
    date,
    category: b.category,
    scheduled: b.scheduled,
    completed: b.completed,
  })))
}

function getWeeklySummary(mondayDate) {
  const monday = new Date(mondayDate + 'T12:00:00')
  const dates = []
  for (let i = 0; i < 5; i++) {
    const d = new Date(monday)
    d.setDate(d.getDate() + i)
    dates.push(d.toISOString().slice(0, 10))
  }
  const placeholders = dates.map(() => '?').join(',')
  const rows = db.prepare(`
    SELECT date, category, blocks_scheduled, blocks_completed
    FROM completion_stats WHERE date IN (${placeholders})
    ORDER BY date, category
  `).all(...dates)

  const total = rows.reduce((acc, r) => ({
    scheduled: acc.scheduled + r.blocks_scheduled,
    completed: acc.completed + r.blocks_completed,
  }), { scheduled: 0, completed: 0 })

  const byCategory = {}
  for (const r of rows) {
    if (!byCategory[r.category]) byCategory[r.category] = { scheduled: 0, completed: 0 }
    byCategory[r.category].scheduled += r.blocks_scheduled
    byCategory[r.category].completed += r.blocks_completed
  }

  return { total, byCategory, rows }
}

function getStreak() {
  const rows = db.prepare(`
    SELECT date,
           SUM(blocks_scheduled) as scheduled,
           SUM(blocks_completed) as completed
    FROM completion_stats
    GROUP BY date
    ORDER BY date DESC
  `).all()

  let streak = 0
  const today = new Date().toISOString().slice(0, 10)

  for (const row of rows) {
    if (row.date > today) continue
    const pct = row.scheduled > 0 ? (row.completed / row.scheduled) : 0
    if (pct >= 0.7) {
      streak++
    } else {
      break
    }
  }
  return streak
}

function getLast4Weeks() {
  const result = []
  const today = new Date()
  // Start from 4 weeks back
  for (let w = 3; w >= 0; w--) {
    const weekStart = new Date(today)
    weekStart.setDate(today.getDate() - today.getDay() + 1 - w * 7) // Monday
    const days = []
    for (let d = 0; d < 5; d++) {
      const day = new Date(weekStart)
      day.setDate(weekStart.getDate() + d)
      const dateStr = day.toISOString().slice(0, 10)
      const row = db.prepare(`
        SELECT SUM(blocks_scheduled) as s, SUM(blocks_completed) as c
        FROM completion_stats WHERE date = ?
      `).get(dateStr)
      const pct = row && row.s > 0 ? row.c / row.s : null
      days.push({ date: dateStr, pct })
    }
    result.push(days)
  }
  return result
}

function getBestWeek() {
  const row = db.prepare(`
    WITH weekly AS (
      SELECT strftime('%Y-W%W', date) as week,
             SUM(blocks_scheduled) as s,
             SUM(blocks_completed) as c
      FROM completion_stats GROUP BY week
    )
    SELECT week, CAST(c AS REAL)/s as pct FROM weekly WHERE s > 0 ORDER BY pct DESC LIMIT 1
  `).get()
  return row || null
}

module.exports = { recordDayStats, getWeeklySummary, getStreak, getLast4Weeks, getBestWeek }

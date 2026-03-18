const db = require('../db/database')

function recordEvent(event) {
  db.prepare(`
    INSERT INTO learning_events (
      event_type, block_category, block_title, scheduled_start, scheduled_end,
      actual_start, actual_end, scheduled_duration_mins, actual_duration_mins,
      day_of_week, hour_of_day, ai_suggestion_type, applied
    ) VALUES (
      @event_type, @block_category, @block_title, @scheduled_start, @scheduled_end,
      @actual_start, @actual_end, @scheduled_duration_mins, @actual_duration_mins,
      @day_of_week, @hour_of_day, @ai_suggestion_type, @applied
    )
  `).run({
    event_type: event.event_type,
    block_category: event.block_category || null,
    block_title: event.block_title || null,
    scheduled_start: event.scheduled_start || null,
    scheduled_end: event.scheduled_end || null,
    actual_start: event.actual_start || null,
    actual_end: event.actual_end || null,
    scheduled_duration_mins: event.scheduled_duration_mins || null,
    actual_duration_mins: event.actual_duration_mins || null,
    day_of_week: event.day_of_week || null,
    hour_of_day: event.hour_of_day || null,
    ai_suggestion_type: event.ai_suggestion_type || null,
    applied: event.applied ? 1 : 0,
  })
}

function getLearningContext() {
  const insights = []

  // Productivity by hour
  const byHour = db.prepare(`
    SELECT hour_of_day,
           COUNT(*) as total,
           SUM(CASE WHEN event_type = 'block_completed' THEN 1 ELSE 0 END) as completed
    FROM learning_events
    WHERE hour_of_day IS NOT NULL
    GROUP BY hour_of_day
    HAVING total >= 3
    ORDER BY CAST(completed AS REAL)/total DESC
  `).all()

  if (byHour.length > 0) {
    const best = byHour[0]
    const worst = byHour[byHour.length - 1]
    insights.push(`Most productive hour: ${best.hour_of_day}:00 (${Math.round(best.completed/best.total*100)}% completion).`)
    if (worst.hour_of_day !== best.hour_of_day) {
      insights.push(`Least productive hour: ${worst.hour_of_day}:00.`)
    }
  }

  // Skip patterns
  const skips = db.prepare(`
    SELECT block_category, block_title, COUNT(*) as skip_count
    FROM learning_events
    WHERE event_type = 'block_skipped'
    GROUP BY block_category, block_title
    HAVING skip_count >= 2
    ORDER BY skip_count DESC
    LIMIT 3
  `).all()

  for (const s of skips) {
    insights.push(`Frequently skipped: "${s.block_title}" (${s.block_category}) — ${s.skip_count} times.`)
  }

  // Time estimation
  const overruns = db.prepare(`
    SELECT block_category,
           AVG(actual_duration_mins - scheduled_duration_mins) as avg_overrun
    FROM learning_events
    WHERE actual_duration_mins IS NOT NULL AND scheduled_duration_mins IS NOT NULL
    GROUP BY block_category
    HAVING ABS(avg_overrun) >= 10
  `).all()

  for (const o of overruns) {
    const dir = o.avg_overrun > 0 ? 'over' : 'under'
    insights.push(`${o.block_category} blocks typically run ${Math.abs(Math.round(o.avg_overrun))} mins ${dir} schedule.`)
  }

  // AI apply rate
  const aiRate = db.prepare(`
    SELECT ai_suggestion_type, AVG(applied) as apply_rate, COUNT(*) as total
    FROM learning_events
    WHERE ai_suggestion_type IS NOT NULL
    GROUP BY ai_suggestion_type
    HAVING total >= 3
  `).all()

  for (const a of aiRate) {
    insights.push(`AI ${a.ai_suggestion_type} suggestions applied ${Math.round(a.apply_rate * 100)}% of the time.`)
  }

  return insights.length > 0
    ? 'User insights: ' + insights.join(' ')
    : 'No learning data yet — schedule data will be collected as you use DayForge.'
}

module.exports = { recordEvent, getLearningContext }

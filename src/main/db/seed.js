function seedTemplates(db) {
  const days = ['mon', 'tue', 'wed', 'thu', 'fri']

  const baseBlocks = [
    { start: '09:00', end: '12:00', category: 'code',    title: 'Deep focus — ThreatForged build' },
    { start: '12:00', end: '12:30', category: 'break',   title: 'Lunch' },
    { start: '12:30', end: '14:30', category: 'content', title: 'Content creation' },
    { start: '14:30', end: '15:30', category: 'upload',  title: 'Publish & schedule' },
    { start: '15:30', end: '17:30', category: 'flex',    title: 'Legal / admin / outreach' },
    { start: '17:30', end: '18:00', category: 'break',   title: 'Transition' },
    { start: '18:00', end: '21:00', category: 'code',    title: 'ThreatForged — overflow / review' },
  ]

  const fridayLastBlock = { start: '18:00', end: '21:00', category: 'break', title: 'EOW — protected, no work' }

  const insert = db.prepare(`
    INSERT INTO schedule_templates (day_of_week, start_time, end_time, category, title)
    VALUES (@day_of_week, @start_time, @end_time, @category, @title)
  `)

  const insertMany = db.transaction((rows) => {
    for (const row of rows) {
      insert.run(row)
    }
  })

  const rows = []
  for (const day of days) {
    const blocks = day === 'fri'
      ? [...baseBlocks.slice(0, 6), fridayLastBlock]
      : baseBlocks

    for (const block of blocks) {
      rows.push({
        day_of_week: day,
        start_time: block.start,
        end_time: block.end,
        category: block.category,
        title: block.title,
      })
    }
  }

  insertMany(rows)
}

module.exports = { seedTemplates }

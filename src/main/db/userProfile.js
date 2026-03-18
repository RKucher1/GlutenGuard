const db = require('./database')

const PROFILE_KEY = 'user_profile'

function save(profile) {
  const json = JSON.stringify(profile)
  db.prepare('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)').run(PROFILE_KEY, json)
  db.prepare('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)').run('onboarding_complete', 'true')
}

function get() {
  const row = db.prepare('SELECT value FROM settings WHERE key = ?').get(PROFILE_KEY)
  if (!row) return null
  try { return JSON.parse(row.value) } catch { return null }
}

/** Convert the stored profile object into a plain-English paragraph for AI prompts. */
function toPromptContext(profile) {
  if (!profile || profile.skipped) return 'No personal profile provided.'

  const lines = []

  if (profile.name) lines.push(`User's name is ${profile.name}.`)

  if (profile.wakeTime) lines.push(`Wakes up around ${profile.wakeTime}.`)
  if (profile.breakfast) lines.push(`Breakfast: ${profile.breakfast}.`)
  if (profile.workStart) lines.push(`Starts work around ${profile.workStart}.`)
  if (profile.workEnd) lines.push(`Ends work around ${profile.workEnd}.`)

  if (profile.pets?.includes('Dog(s)')) {
    const times = profile.dogWalkTimes?.join(', ') || 'morning and evening'
    const dur = profile.dogWalkDuration || '20 min'
    lines.push(`Has dogs — needs ${dur} walks ${times}.`)
  }
  if (profile.pets?.some(p => p !== 'Dog(s)' && p !== 'No pets')) {
    lines.push(`Has pets: ${profile.pets.filter(p => p !== 'Dog(s)').join(', ')}.`)
  }

  if (profile.lunchTime) lines.push(`Eats lunch around ${profile.lunchTime}${profile.lunchStyle ? ` (${profile.lunchStyle})` : ''}.`)
  if (profile.dinnerTime) lines.push(`Dinner around ${profile.dinnerTime}${profile.dinnerStyle ? ` (${profile.dinnerStyle})` : ''}.`)

  if (profile.exerciseFreq && profile.exerciseFreq !== 'Not currently' && profile.exerciseFreq !== 'Rarely') {
    const types = profile.exerciseTypes?.join(', ') || 'workout'
    const when = profile.exerciseTime || ''
    const dur = profile.exerciseDuration || ''
    lines.push(`Works out ${profile.exerciseFreq} — ${types}${when ? `, ${when}` : ''}${dur ? `, ~${dur}` : ''}.`)
  }

  if (profile.kids && profile.kids !== 'No kids') {
    lines.push(`Has kids (${profile.kids.toLowerCase()}).`)
    if (profile.schoolRun?.length) lines.push(`School run: ${profile.schoolRun.join(', ')}.`)
  }

  if (profile.commute && profile.commute !== 'Fully remote') lines.push(`Commute: ${profile.commute}.`)
  if (profile.household) lines.push(`Lives with: ${profile.household.toLowerCase()}.`)

  if (profile.peakTime) lines.push(`Peak productivity: ${profile.peakTime.toLowerCase()}.`)
  if (profile.breakFreq) lines.push(`Takes breaks ${profile.breakFreq.toLowerCase()}.`)
  if (profile.caffeine && profile.caffeine !== 'Neither') lines.push(`${profile.caffeine}.`)

  if (profile.eveningHabits?.length) lines.push(`Evening habits: ${profile.eveningHabits.join(', ')}.`)
  if (profile.bedTime) lines.push(`Aims to sleep by ${profile.bedTime}.`)

  if (profile.freeform?.trim()) lines.push(`Note: ${profile.freeform.trim()}`)

  return lines.length > 0 ? lines.join(' ') : 'No personal profile provided.'
}

module.exports = { save, get, toPromptContext }

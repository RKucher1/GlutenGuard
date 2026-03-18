const { ipcMain } = require('electron')
const blocks = require('./db/blocks')
const templates = require('./db/templates')
const meetings = require('./db/meetings')
const completionStats = require('./db/completionStats')
const settingsDb = require('./db/settingsDb')
const { generateWeek } = require('./services/scheduler')
const { detectConflicts } = require('./services/conflictDetector')
const aiService = require('./services/aiService')
const activityMonitor = require('./services/activityMonitor')
const learningService = require('./services/learningService')

let gcalService = null
try { gcalService = require('./services/gcalService') } catch (e) {}

let notificationService = null
try { notificationService = require('./services/notificationService') } catch (e) {}

function wrap(fn) {
  return async (event, args) => {
    try {
      const result = await fn(event, args)
      return { data: result }
    } catch (err) {
      return { success: false, error: err.message }
    }
  }
}

function registerIpcHandlers() {
  // ── Blocks ────────────────────────────────────────────────────────────
  ipcMain.handle('blocks:getByDate', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    return blocks.getByDate(args.date)
  }))

  ipcMain.handle('blocks:getByWeek', wrap(async (e, args) => {
    return blocks.getByWeek(args.mondayDate)
  }))

  ipcMain.handle('blocks:updateStatus', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    blocks.updateStatus(args.id, args.status, args.note)
    // Record learning event
    const allBlocks = blocks.getByDate(args.date || new Date().toISOString().slice(0, 10))
    const block = allBlocks.find(b => b.id === args.id)
    if (block) {
      const d = new Date()
      learningService.recordEvent({
        event_type: args.status === 'done' ? 'block_completed' : args.status === 'skipped' ? 'block_skipped' : 'block_partial',
        block_category: block.category,
        block_title: block.title,
        scheduled_start: block.start_time,
        scheduled_end: block.end_time,
        hour_of_day: parseInt(block.start_time.split(':')[0]),
        day_of_week: d.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase(),
      })
    }
    return { updated: true }
  }))

  ipcMain.handle('blocks:update', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    blocks.update(args.id, args.fields)
    return { updated: true }
  }))

  ipcMain.handle('blocks:generateWeek', wrap(async (e, args) => {
    return generateWeek(args.mondayDate)
  }))

  // ── Templates ─────────────────────────────────────────────────────────
  ipcMain.handle('templates:getAll', wrap(async () => templates.getAll()))
  ipcMain.handle('templates:reset', wrap(async () => templates.reset()))

  // ── Meetings ──────────────────────────────────────────────────────────
  ipcMain.handle('meetings:getForDate', wrap(async (e, args) => {
    return meetings.getForDate(args.date)
  }))

  ipcMain.handle('meetings:getForWeek', wrap(async (e, args) => {
    return meetings.getForWeek(args.mondayDate)
  }))

  ipcMain.handle('meetings:create', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    const id = meetings.create(args.meeting)
    return { id }
  }))

  ipcMain.handle('meetings:update', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    meetings.update(args.id, args.fields)
    return { updated: true }
  }))

  ipcMain.handle('meetings:delete', wrap(async (e, args) => {
    meetings.remove(args.id)
    return { deleted: true }
  }))

  ipcMain.handle('meetings:checkConflicts', wrap(async (e, args) => {
    const { proposed, date } = args
    const dayBlocks = blocks.getByDate(date || proposed.date)
    const dayMeetings = meetings.getForDate(date || proposed.date)
    return detectConflicts(proposed, dayBlocks, dayMeetings)
  }))

  // ── AI ────────────────────────────────────────────────────────────────
  ipcMain.handle('ai:replanDay', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    const result = await aiService.replanDay(args.schedule, args.currentTime, args.completedBlocks)
    learningService.recordEvent({ event_type: 'ai_applied', ai_suggestion_type: 'replan', applied: 0 })
    return result
  }))

  ipcMain.handle('ai:planWeek', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    return aiService.planWeek(args.template, args.meetings, args.request)
  }))

  ipcMain.handle('ai:chat', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    const learningCtx = learningService.getLearningContext()
    return aiService.chat(args.schedule, args.meetings, args.message, args.history, args.completedBlocks, learningCtx)
  }))

  ipcMain.handle('ai:morningBriefing', wrap(async (e, args) => {
    const learningCtx = learningService.getLearningContext()
    return aiService.morningBriefing(args.userFocus, args.scheduleTemplate, args.gcalEvents, args.completionHistory, learningCtx)
  }))

  ipcMain.handle('ai:applyChanges', wrap(async (e, args) => {
    activityMonitor.recordActivity()
    const { changes, proposedMeetings } = args
    if (changes) {
      for (const c of changes) {
        const fields = {}
        if (c.new_start_time) fields.start_time = c.new_start_time
        if (c.new_end_time) fields.end_time = c.new_end_time
        if (c.new_title) fields.title = c.new_title
        blocks.update(c.block_id, fields)
      }
    }
    if (proposedMeetings) {
      for (const m of proposedMeetings) {
        meetings.create(m)
      }
    }
    // Reschedule notifications
    const today = new Date().toISOString().slice(0, 10)
    const todayBlocks = blocks.getByDate(today)
    if (notificationService) notificationService.rescheduleNotifications(todayBlocks)
    return { applied: true }
  }))

  // ── GCal ──────────────────────────────────────────────────────────────
  ipcMain.handle('gcal:sync', wrap(async (e, args) => {
    if (!gcalService) throw new Error('GCal service unavailable')
    return gcalService.syncToLocal(args.mondayDate)
  }))

  // ── Stats ─────────────────────────────────────────────────────────────
  ipcMain.handle('stats:recordDay', wrap(async (e, args) => {
    completionStats.recordDayStats(args.date)
    return { recorded: true }
  }))

  ipcMain.handle('stats:getWeekly', wrap(async (e, args) => {
    return completionStats.getWeeklySummary(args.mondayDate)
  }))

  ipcMain.handle('stats:getStreak', wrap(async () => {
    return { streak: completionStats.getStreak() }
  }))

  ipcMain.handle('stats:getLast4Weeks', wrap(async () => {
    return completionStats.getLast4Weeks()
  }))

  ipcMain.handle('stats:getBestWeek', wrap(async () => {
    return completionStats.getBestWeek()
  }))

  // ── Settings ──────────────────────────────────────────────────────────
  ipcMain.handle('settings:get', wrap(async (e, args) => {
    return settingsDb.get(args.key)
  }))

  ipcMain.handle('settings:set', wrap(async (e, args) => {
    settingsDb.set(args.key, args.value)
    if (args.key === 'inactivity_threshold_mins') {
      activityMonitor.startMonitoring(parseInt(args.value))
    }
    return { set: true }
  }))

  ipcMain.handle('settings:getAll', wrap(async () => {
    return settingsDb.getAll()
  }))

  // ── Learning ──────────────────────────────────────────────────────────
  ipcMain.handle('learning:recordEvent', wrap(async (e, args) => {
    learningService.recordEvent(args.event)
    return { recorded: true }
  }))

  ipcMain.handle('learning:getContext', wrap(async () => {
    return learningService.getLearningContext()
  }))

  // ── Activity ──────────────────────────────────────────────────────────
  ipcMain.handle('activity:record', wrap(async () => {
    activityMonitor.recordActivity()
    return { recorded: true }
  }))

  // Start activity monitor
  const thresholdMins = parseInt(settingsDb.get('inactivity_threshold_mins') || '90')
  activityMonitor.startMonitoring(thresholdMins)

  // Schedule today's notifications on startup
  try {
    const today = new Date().toISOString().slice(0, 10)
    const notificationsEnabled = settingsDb.get('notifications_enabled')
    if (notificationsEnabled !== 'false' && notificationService) {
      const todayBlocks = blocks.getByDate(today)
      notificationService.scheduleBlockNotifications(todayBlocks)
    }
  } catch (e) {}
}

module.exports = { registerIpcHandlers }

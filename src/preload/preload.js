const { contextBridge, ipcRenderer } = require('electron')

const ALLOWED_CHANNELS = [
  'blocks:getByDate', 'blocks:getByWeek', 'blocks:updateStatus', 'blocks:update', 'blocks:generateWeek',
  'templates:getAll', 'templates:reset',
  'meetings:getForDate', 'meetings:getForWeek', 'meetings:create', 'meetings:update', 'meetings:delete', 'meetings:checkConflicts',
  'ai:replanDay', 'ai:planWeek', 'ai:chat', 'ai:morningBriefing', 'ai:applyChanges',
  'gcal:sync',
  'stats:recordDay', 'stats:getWeekly', 'stats:getStreak', 'stats:getLast4Weeks', 'stats:getBestWeek',
  'settings:get', 'settings:set', 'settings:getAll',
  'learning:recordEvent', 'learning:getContext',
  'activity:record',
]

// Legacy invoke pattern (used by existing renderer code)
contextBridge.exposeInMainWorld('electronAPI', {
  invoke: (channel, args) => {
    if (!ALLOWED_CHANNELS.includes(channel)) {
      throw new Error('IPC channel not allowed: ' + channel)
    }
    return ipcRenderer.invoke(channel, args)
  },
  on: (channel, callback) => {
    ipcRenderer.on(channel, callback)
  },
})

// Structured API (used by new Phase 2-5 renderer code)
contextBridge.exposeInMainWorld('api', {
  blocks: {
    getByDate: (date) => ipcRenderer.invoke('blocks:getByDate', { date }),
    getByWeek: (mondayDate) => ipcRenderer.invoke('blocks:getByWeek', { mondayDate }),
    updateStatus: (id, status, note, date) => ipcRenderer.invoke('blocks:updateStatus', { id, status, note, date }),
    update: (id, fields) => ipcRenderer.invoke('blocks:update', { id, fields }),
    generateWeek: (mondayDate) => ipcRenderer.invoke('blocks:generateWeek', { mondayDate }),
  },
  templates: {
    getAll: () => ipcRenderer.invoke('templates:getAll'),
    reset: () => ipcRenderer.invoke('templates:reset'),
  },
  meetings: {
    getForDate: (date) => ipcRenderer.invoke('meetings:getForDate', { date }),
    getForWeek: (mondayDate) => ipcRenderer.invoke('meetings:getForWeek', { mondayDate }),
    create: (meeting) => ipcRenderer.invoke('meetings:create', { meeting }),
    update: (id, fields) => ipcRenderer.invoke('meetings:update', { id, fields }),
    delete: (id) => ipcRenderer.invoke('meetings:delete', { id }),
    checkConflicts: (proposed, date) => ipcRenderer.invoke('meetings:checkConflicts', { proposed, date }),
  },
  ai: {
    replanDay: (schedule, currentTime, completedBlocks) => ipcRenderer.invoke('ai:replanDay', { schedule, currentTime, completedBlocks }),
    planWeek: (template, meetings, request) => ipcRenderer.invoke('ai:planWeek', { template, meetings, request }),
    chat: (schedule, meetings, message, history, completedBlocks) => ipcRenderer.invoke('ai:chat', { schedule, meetings, message, history, completedBlocks }),
    morningBriefing: (userFocus, scheduleTemplate, gcalEvents, completionHistory) => ipcRenderer.invoke('ai:morningBriefing', { userFocus, scheduleTemplate, gcalEvents, completionHistory }),
    applyChanges: (changes, proposedMeetings) => ipcRenderer.invoke('ai:applyChanges', { changes, proposedMeetings }),
  },
  gcal: {
    sync: (mondayDate) => ipcRenderer.invoke('gcal:sync', { mondayDate }),
  },
  stats: {
    recordDay: (date) => ipcRenderer.invoke('stats:recordDay', { date }),
    getWeekly: (mondayDate) => ipcRenderer.invoke('stats:getWeekly', { mondayDate }),
    getStreak: () => ipcRenderer.invoke('stats:getStreak'),
    getLast4Weeks: () => ipcRenderer.invoke('stats:getLast4Weeks'),
    getBestWeek: () => ipcRenderer.invoke('stats:getBestWeek'),
  },
  settings: {
    get: (key) => ipcRenderer.invoke('settings:get', { key }),
    set: (key, value) => ipcRenderer.invoke('settings:set', { key, value }),
    getAll: () => ipcRenderer.invoke('settings:getAll'),
  },
  learning: {
    recordEvent: (event) => ipcRenderer.invoke('learning:recordEvent', { event }),
    getContext: () => ipcRenderer.invoke('learning:getContext'),
  },
  activity: {
    record: () => ipcRenderer.invoke('activity:record'),
  },
})

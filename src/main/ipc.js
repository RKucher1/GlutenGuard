const { ipcMain } = require('electron')
const blocks = require('./db/blocks')
const templates = require('./db/templates')
const { generateWeek } = require('./services/scheduler')

function registerIpcHandlers() {
  ipcMain.handle('blocks:getByDate', async (event, args) => {
    try {
      const result = blocks.getByDate(args.date)
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })

  ipcMain.handle('blocks:updateStatus', async (event, args) => {
    try {
      const result = blocks.updateStatus(args.id, args.status, args.note)
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })

  ipcMain.handle('blocks:update', async (event, args) => {
    try {
      const result = blocks.update(args.id, args.fields)
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })

  ipcMain.handle('blocks:generateWeek', async (event, args) => {
    try {
      const result = generateWeek(args.mondayDate)
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })

  ipcMain.handle('templates:getAll', async (event) => {
    try {
      const result = templates.getAll()
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })

  ipcMain.handle('templates:reset', async (event) => {
    try {
      const result = templates.reset()
      return { data: result }
    } catch (err) {
      return { error: err.message }
    }
  })
}

module.exports = { registerIpcHandlers }

const { contextBridge, ipcRenderer } = require('electron')

const ALLOWED_CHANNELS = [
  'blocks:getByDate',
  'blocks:updateStatus',
  'blocks:update',
  'blocks:generateWeek',
  'templates:getAll',
  'templates:reset',
]

contextBridge.exposeInMainWorld('electronAPI', {
  invoke: (channel, args) => {
    if (!ALLOWED_CHANNELS.includes(channel)) {
      throw new Error('IPC channel not allowed: ' + channel)
    }
    return ipcRenderer.invoke(channel, args)
  },
})

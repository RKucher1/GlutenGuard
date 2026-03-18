const { Notification, BrowserWindow } = require('electron')

let lastActivityTime = Date.now()
let monitorInterval = null

function recordActivity() {
  lastActivityTime = Date.now()
}

function sendInactivityNotification() {
  if (!Notification.isSupported()) return
  const n = new Notification({
    title: 'DayForge',
    body: 'Still on track? Your schedule might need a replan.',
  })
  n.on('click', () => {
    const win = BrowserWindow.getAllWindows()[0]
    if (win) {
      win.show()
      win.focus()
      win.webContents.send('open-chat-panel', 'Looks like you\'ve been away for a while. Want me to replan the rest of your day?')
    }
  })
  n.show()
}

function startMonitoring(thresholdMins) {
  if (monitorInterval) clearInterval(monitorInterval)
  const threshold = (thresholdMins || 90) * 60 * 1000

  monitorInterval = setInterval(() => {
    const elapsed = Date.now() - lastActivityTime
    const hour = new Date().getHours()
    const day = new Date().getDay()
    const isWeekday = day >= 1 && day <= 5

    if (elapsed >= threshold && hour >= 9 && hour < 21 && isWeekday) {
      sendInactivityNotification()
      lastActivityTime = Date.now()
    }
  }, 60000)
}

function stopMonitoring() {
  if (monitorInterval) {
    clearInterval(monitorInterval)
    monitorInterval = null
  }
}

module.exports = { recordActivity, startMonitoring, stopMonitoring }

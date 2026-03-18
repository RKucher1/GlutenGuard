const { Notification, BrowserWindow } = require('electron')

const scheduledTimers = []

function scheduleBlockNotifications(blocks) {
  cancelAllNotifications()
  const now = new Date()
  const todayStr = now.toISOString().slice(0, 10)

  for (const block of blocks) {
    const [h, m] = block.start_time.split(':').map(Number)
    const blockStart = new Date(todayStr + 'T' + block.start_time + ':00')
    const twoMinBefore = new Date(blockStart.getTime() - 2 * 60 * 1000)

    if (twoMinBefore > now) {
      const delay = twoMinBefore.getTime() - now.getTime()
      const timer = setTimeout(() => {
        if (Notification.isSupported()) {
          new Notification({
            title: 'DayForge',
            body: `${block.title} starting in 2 minutes`,
          }).show()
        }
      }, delay)
      scheduledTimers.push(timer)
    }

    const [eh, em] = block.end_time.split(':').map(Number)
    const blockEnd = new Date(todayStr + 'T' + block.end_time + ':00')

    if (blockEnd > now) {
      const delay = blockEnd.getTime() - now.getTime()
      const timer = setTimeout(() => {
        if (Notification.isSupported()) {
          const n = new Notification({
            title: 'DayForge',
            body: `${block.title} — time's up. How'd it go?`,
          })
          n.on('click', () => {
            const win = BrowserWindow.getAllWindows()[0]
            if (win) { win.show(); win.focus() }
          })
          n.show()
        }
      }, delay)
      scheduledTimers.push(timer)
    }
  }
}

function cancelAllNotifications() {
  while (scheduledTimers.length) {
    clearTimeout(scheduledTimers.pop())
  }
}

function rescheduleNotifications(newBlocks) {
  cancelAllNotifications()
  scheduleBlockNotifications(newBlocks)
}

module.exports = { scheduleBlockNotifications, cancelAllNotifications, rescheduleNotifications }

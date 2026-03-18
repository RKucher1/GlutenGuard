const path = require('path')
const fs = require('fs')
const { app } = require('electron')

function getTokenPath() {
  return path.join(app.getPath('appData'), 'DayForge', 'gcal_token.json')
}

function getCredentialsPath() {
  return path.join(app.getPath('appData'), 'DayForge', 'gcal_credentials.json')
}

async function authenticate() {
  try {
    const { google } = require('googleapis')
    const credPath = getCredentialsPath()
    if (!fs.existsSync(credPath)) {
      throw new Error('Google Calendar credentials not found. Please add gcal_credentials.json to your DayForge data folder.')
    }
    const credentials = JSON.parse(fs.readFileSync(credPath, 'utf8'))
    const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web
    const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0])

    const tokenPath = getTokenPath()
    if (fs.existsSync(tokenPath)) {
      const token = JSON.parse(fs.readFileSync(tokenPath, 'utf8'))
      oAuth2Client.setCredentials(token)
      return oAuth2Client
    }
    throw new Error('Not authenticated with Google Calendar. Please complete OAuth flow.')
  } catch (err) {
    throw new Error('GCal auth failed: ' + err.message)
  }
}

async function getEventsForWeek(mondayDate) {
  const auth = await authenticate()
  const { google } = require('googleapis')
  const calendar = google.calendar({ version: 'v3', auth })

  const monday = new Date(mondayDate + 'T00:00:00')
  const friday = new Date(mondayDate + 'T00:00:00')
  friday.setDate(friday.getDate() + 5)

  const res = await calendar.events.list({
    calendarId: 'primary',
    timeMin: monday.toISOString(),
    timeMax: friday.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
  })

  return (res.data.items || []).map(event => {
    const isAllDay = !event.start.dateTime
    return {
      gcal_event_id: event.id,
      title: event.summary || 'Untitled',
      date: (event.start.dateTime || event.start.date).slice(0, 10),
      start_time: isAllDay
        ? '00:00'
        : new Date(event.start.dateTime).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false }),
      end_time: isAllDay
        ? '23:59'
        : new Date(event.end.dateTime).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false }),
      description: (isAllDay ? '[All-day] ' : '') + (event.description || ''),
      source: 'gcal',
    }
  })
}

async function syncToLocal(mondayDate) {
  const meetings = require('../db/meetings')
  const events = await getEventsForWeek(mondayDate)
  for (const event of events) {
    try {
      meetings.upsertGcal(event)
    } catch (err) {
      // Skip events that fail to upsert
    }
  }
  return { synced: events.length }
}

module.exports = { authenticate, getEventsForWeek, syncToLocal }

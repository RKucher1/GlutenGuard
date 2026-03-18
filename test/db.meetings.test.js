'use strict'
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { setup, teardown } = require('./helpers/testDb')

const TODAY = '2026-03-18'
const MONDAY = '2026-03-16'

describe('meetings DB', () => {
  let meetings

  before(() => {
    const mods = setup()
    meetings = mods.meetings
  })

  after(() => teardown())

  it('getForDate returns empty array when no meetings', () => {
    const rows = meetings.getForDate(TODAY)
    assert.deepStrictEqual(rows, [])
  })

  it('create inserts a meeting and returns id', () => {
    const id = meetings.create({
      date: TODAY,
      title: 'Standup',
      start_time: '10:00',
      end_time: '10:30',
    })
    assert.ok(typeof id === 'number' || typeof id === 'bigint')
  })

  it('getForDate returns created meeting', () => {
    const rows = meetings.getForDate(TODAY)
    assert.ok(rows.length >= 1)
    assert.strictEqual(rows[0].title, 'Standup')
  })

  it('create uses defaults for optional fields', () => {
    const id = meetings.create({
      date: TODAY,
      title: 'Optional Test',
      start_time: '11:00',
      end_time: '11:30',
    })
    const rows = meetings.getForDate(TODAY)
    const m = rows.find(r => r.id === Number(id))
    assert.strictEqual(m.source, 'local')
    assert.strictEqual(m.color, '#4CB8CC')
    assert.strictEqual(m.description, '')
  })

  it('update modifies allowed fields', () => {
    const id = meetings.create({
      date: TODAY, title: 'Before', start_time: '14:00', end_time: '15:00',
    })
    meetings.update(Number(id), { title: 'After', description: 'Updated' })
    const rows = meetings.getForDate(TODAY)
    const m = rows.find(r => r.id === Number(id))
    assert.strictEqual(m.title, 'After')
    assert.strictEqual(m.description, 'Updated')
  })

  it('update ignores disallowed fields', () => {
    const id = meetings.create({
      date: TODAY, title: 'Safe', start_time: '16:00', end_time: '17:00',
    })
    // source is not in allowed fields
    meetings.update(Number(id), { source: 'hacked' })
    const rows = meetings.getForDate(TODAY)
    const m = rows.find(r => r.id === Number(id))
    assert.strictEqual(m.source, 'local')
  })

  it('remove deletes a meeting', () => {
    const id = meetings.create({
      date: TODAY, title: 'ToDelete', start_time: '08:00', end_time: '08:30',
    })
    meetings.remove(Number(id))
    const rows = meetings.getForDate(TODAY)
    assert.ok(!rows.find(r => r.id === Number(id)))
  })

  it('getForWeek returns meetings for 5 weekdays', () => {
    // Create one meeting per day Mon-Fri
    for (let i = 0; i < 5; i++) {
      const d = new Date(MONDAY + 'T12:00:00')
      d.setDate(d.getDate() + i)
      meetings.create({
        date: d.toISOString().slice(0, 10),
        title: `Day ${i}`,
        start_time: '09:00',
        end_time: '10:00',
      })
    }
    const rows = meetings.getForWeek(MONDAY)
    // Should include all 5 day meetings (plus any created in TODAY tests if TODAY is in the week)
    const dayMeetings = rows.filter(r => r.title.startsWith('Day '))
    assert.strictEqual(dayMeetings.length, 5)
  })

  it('upsertGcal inserts new gcal event', () => {
    meetings.upsertGcal({
      date: TODAY,
      title: 'GCal Event',
      start_time: '13:00',
      end_time: '14:00',
      description: '',
      color: '#4CB8CC',
      gcal_event_id: 'gcal_abc_123',
    })
    const rows = meetings.getForDate(TODAY)
    const m = rows.find(r => r.gcal_event_id === 'gcal_abc_123')
    assert.ok(m)
    assert.strictEqual(m.source, 'gcal')
  })

  it('upsertGcal updates existing gcal event on conflict', () => {
    meetings.upsertGcal({
      date: TODAY,
      title: 'GCal Updated',
      start_time: '13:30',
      end_time: '14:30',
      description: 'changed',
      color: '#4CB8CC',
      gcal_event_id: 'gcal_abc_123',
    })
    const rows = meetings.getForDate(TODAY)
    const matches = rows.filter(r => r.gcal_event_id === 'gcal_abc_123')
    assert.strictEqual(matches.length, 1)
    assert.strictEqual(matches[0].title, 'GCal Updated')
    assert.strictEqual(matches[0].start_time, '13:30')
  })
})

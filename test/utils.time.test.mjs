import { describe, it } from 'node:test'
import assert from 'node:assert'
import {
  timeToMinutes,
  minutesToTime,
  timeToPercent,
  durationMinutes,
  overlaps,
  formatDuration,
  getMondayOfWeek,
  formatDisplayDate,
} from '../src/renderer/utils/time.js'

describe('timeToMinutes', () => {
  it('converts HH:MM to total minutes', () => {
    assert.strictEqual(timeToMinutes('09:00'), 540)
    assert.strictEqual(timeToMinutes('00:00'), 0)
    assert.strictEqual(timeToMinutes('23:59'), 1439)
    assert.strictEqual(timeToMinutes('12:30'), 750)
  })
})

describe('minutesToTime', () => {
  it('converts minutes back to HH:MM', () => {
    assert.strictEqual(minutesToTime(540), '09:00')
    assert.strictEqual(minutesToTime(0), '00:00')
    assert.strictEqual(minutesToTime(750), '12:30')
    assert.strictEqual(minutesToTime(90), '01:30')
  })

  it('is inverse of timeToMinutes', () => {
    assert.strictEqual(minutesToTime(timeToMinutes('14:45')), '14:45')
  })
})

describe('timeToPercent', () => {
  it('returns 0 for day start', () => {
    assert.strictEqual(timeToPercent('09:00'), 0)
  })

  it('returns 100 for day end', () => {
    assert.strictEqual(timeToPercent('21:00'), 100)
  })

  it('returns 50 for midpoint', () => {
    assert.strictEqual(timeToPercent('15:00'), 50)
  })

  it('accepts custom day bounds', () => {
    const pct = timeToPercent('10:00', '08:00', '12:00')
    assert.strictEqual(pct, 50)
  })
})

describe('durationMinutes', () => {
  it('computes duration correctly', () => {
    assert.strictEqual(durationMinutes('09:00', '12:00'), 180)
    assert.strictEqual(durationMinutes('14:30', '15:00'), 30)
    assert.strictEqual(durationMinutes('00:00', '23:59'), 1439)
  })
})

describe('overlaps', () => {
  it('detects overlap when blocks share time', () => {
    assert.ok(overlaps(
      { start_time: '09:00', end_time: '11:00' },
      { start_time: '10:00', end_time: '12:00' }
    ))
  })

  it('no overlap for adjacent blocks', () => {
    assert.ok(!overlaps(
      { start_time: '09:00', end_time: '11:00' },
      { start_time: '11:00', end_time: '12:00' }
    ))
  })

  it('no overlap for non-adjacent blocks', () => {
    assert.ok(!overlaps(
      { start_time: '09:00', end_time: '10:00' },
      { start_time: '11:00', end_time: '12:00' }
    ))
  })

  it('detects complete containment', () => {
    assert.ok(overlaps(
      { start_time: '09:00', end_time: '13:00' },
      { start_time: '10:00', end_time: '12:00' }
    ))
  })
})

describe('formatDuration', () => {
  it('formats hours and minutes', () => {
    assert.strictEqual(formatDuration(90), '1h 30m')
    assert.strictEqual(formatDuration(60), '1h')
    assert.strictEqual(formatDuration(45), '45m')
    assert.strictEqual(formatDuration(120), '2h')
  })
})

describe('getMondayOfWeek', () => {
  it('returns Monday for a Wednesday', () => {
    assert.strictEqual(getMondayOfWeek('2026-03-18'), '2026-03-16')
  })

  it('returns same day for Monday', () => {
    assert.strictEqual(getMondayOfWeek('2026-03-16'), '2026-03-16')
  })

  it('returns previous Monday for Sunday', () => {
    assert.strictEqual(getMondayOfWeek('2026-03-15'), '2026-03-09')
  })

  it('returns previous Monday for Saturday', () => {
    assert.strictEqual(getMondayOfWeek('2026-03-14'), '2026-03-09')
  })
})

describe('formatDisplayDate', () => {
  it('returns a human-readable date string', () => {
    const result = formatDisplayDate('2026-03-16')
    assert.ok(result.includes('Monday'))
    assert.ok(result.includes('March'))
    assert.ok(result.includes('16'))
  })
})

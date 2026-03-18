const { detectConflicts } = require('../src/main/services/conflictDetector')
const { describe, it } = require('node:test')
const assert = require('node:assert')

describe('detectConflicts', () => {
  const existingBlock = { title: 'Deep Focus', start_time: '09:00', end_time: '12:00' }
  const existingMeeting = { title: 'Team Standup', start_time: '14:00', end_time: '15:00' }

  it('no overlap → hasConflict: false', () => {
    const proposed = { start_time: '13:00', end_time: '14:00' }
    const result = detectConflicts(proposed, [existingBlock], [existingMeeting])
    assert.strictEqual(result.hasConflict, false)
    assert.deepStrictEqual(result.conflicts, [])
  })

  it('partial overlap start → hasConflict: true', () => {
    const proposed = { start_time: '08:00', end_time: '10:00' }
    const result = detectConflicts(proposed, [existingBlock], [])
    assert.strictEqual(result.hasConflict, true)
    assert.strictEqual(result.conflicts.length, 1)
  })

  it('partial overlap end → hasConflict: true', () => {
    const proposed = { start_time: '11:00', end_time: '13:00' }
    const result = detectConflicts(proposed, [existingBlock], [])
    assert.strictEqual(result.hasConflict, true)
    assert.strictEqual(result.conflicts.length, 1)
  })

  it('complete containment → hasConflict: true', () => {
    const proposed = { start_time: '10:00', end_time: '11:00' }
    const result = detectConflicts(proposed, [existingBlock], [])
    assert.strictEqual(result.hasConflict, true)
  })

  it('adjacent (touching, not overlapping) → hasConflict: false', () => {
    const proposed = { start_time: '12:00', end_time: '13:00' }
    const result = detectConflicts(proposed, [existingBlock], [])
    assert.strictEqual(result.hasConflict, false)
  })
})

'use strict'
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { setup, teardown } = require('./helpers/testDb')

const MONDAY = '2026-03-16'  // A known Monday
const WEDNESDAY = '2026-03-18'
const SATURDAY = '2026-03-21'

describe('blocks DB', () => {
  let blocks

  before(() => {
    const mods = setup()
    blocks = mods.blocks
  })

  after(() => teardown())

  it('getByDate auto-generates blocks from template on first access', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    assert.ok(rows.length > 0, 'should auto-generate blocks')
  })

  it('generated blocks have required fields', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    for (const row of rows) {
      assert.ok(row.id)
      assert.ok(row.date)
      assert.ok(row.start_time)
      assert.ok(row.end_time)
      assert.ok(row.category)
      assert.ok(row.title)
      assert.strictEqual(row.status, 'pending')
    }
  })

  it('getByDate is idempotent — second call returns same blocks', () => {
    const first = blocks.getByDate(WEDNESDAY)
    const second = blocks.getByDate(WEDNESDAY)
    assert.strictEqual(first.length, second.length)
    assert.strictEqual(first[0].id, second[0].id)
  })

  it('returns empty array for weekends', () => {
    const rows = blocks.getByDate(SATURDAY)
    assert.deepStrictEqual(rows, [])
  })

  it('updateStatus sets status correctly', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    const block = rows[0]
    blocks.updateStatus(block.id, 'done', 'finished early')
    const updated = blocks.getByDate(WEDNESDAY).find(b => b.id === block.id)
    assert.strictEqual(updated.status, 'done')
    assert.strictEqual(updated.completion_note, 'finished early')
  })

  it('updateStatus rejects invalid status', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    assert.throws(
      () => blocks.updateStatus(rows[0].id, 'invalid_status'),
      /Invalid status/
    )
  })

  it('updateStatus accepts all valid statuses', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    for (const [i, status] of ['pending', 'done', 'partial', 'skipped'].entries()) {
      const block = rows[i % rows.length]
      assert.doesNotThrow(() => blocks.updateStatus(block.id, status))
    }
  })

  it('update modifies allowed fields', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    const block = rows[0]
    blocks.update(block.id, { title: 'New Title', start_time: '09:30' })
    const updated = blocks.getByDate(WEDNESDAY).find(b => b.id === block.id)
    assert.strictEqual(updated.title, 'New Title')
    assert.strictEqual(updated.start_time, '09:30')
  })

  it('update with no allowed fields is a no-op', () => {
    const rows = blocks.getByDate(WEDNESDAY)
    const block = rows[0]
    assert.doesNotThrow(() => blocks.update(block.id, { nonexistent: 'x' }))
  })

  it('getByWeek returns blocks for Mon–Fri', () => {
    const rows = blocks.getByWeek(MONDAY)
    assert.ok(rows.length > 0)
    const dates = [...new Set(rows.map(b => b.date))]
    assert.ok(dates.includes(MONDAY))
    // Should not include Saturday
    assert.ok(!dates.includes(SATURDAY))
  })
})

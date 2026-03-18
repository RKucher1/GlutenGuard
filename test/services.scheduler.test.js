'use strict'
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { setup, teardown } = require('./helpers/testDb')

describe('scheduler.generateWeek', () => {
  let mods

  before(() => {
    mods = setup()
  })

  after(() => {
    teardown()
  })

  it('generates blocks for 5 weekdays', () => {
    // Require scheduler after DB is injected
    const { generateWeek } = require('../src/main/services/scheduler')
    const result = generateWeek('2026-03-16') // Monday
    assert.strictEqual(result.generated, 5)
    assert.strictEqual(result.dates.length, 5)
  })

  it('dates span Mon–Fri of the given week', () => {
    const { generateWeek } = require('../src/main/services/scheduler')
    const result = generateWeek('2026-03-16')
    assert.strictEqual(result.dates[0], '2026-03-16')
    assert.strictEqual(result.dates[4], '2026-03-20')
  })

  it('idempotent — calling twice does not throw', () => {
    const { generateWeek } = require('../src/main/services/scheduler')
    assert.doesNotThrow(() => generateWeek('2026-03-16'))
  })
})

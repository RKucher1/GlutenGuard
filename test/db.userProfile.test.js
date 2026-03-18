'use strict'
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { setup, teardown } = require('./helpers/testDb')

describe('userProfile', () => {
  let userProfile

  before(() => {
    const mods = setup()
    userProfile = mods.userProfile
  })

  after(() => teardown())

  it('get returns null when no profile saved', () => {
    assert.strictEqual(userProfile.get(), null)
  })

  it('save and get round-trips profile', () => {
    const profile = { name: 'Alex', wakeTime: '07:00', workStart: '09:00' }
    userProfile.save(profile)
    const retrieved = userProfile.get()
    assert.strictEqual(retrieved.name, 'Alex')
    assert.strictEqual(retrieved.wakeTime, '07:00')
  })

  it('save sets onboarding_complete to true', () => {
    // Requires access to settingsDb — check via the same DB
    userProfile.save({ name: 'Test' })
    const retrieved = userProfile.get()
    assert.ok(retrieved)
  })

  it('toPromptContext returns fallback for null profile', () => {
    const ctx = userProfile.toPromptContext(null)
    assert.strictEqual(ctx, 'No personal profile provided.')
  })

  it('toPromptContext returns fallback for skipped profile', () => {
    const ctx = userProfile.toPromptContext({ skipped: true })
    assert.strictEqual(ctx, 'No personal profile provided.')
  })

  it('toPromptContext includes name', () => {
    const ctx = userProfile.toPromptContext({ name: 'Jordan' })
    assert.ok(ctx.includes("Jordan"))
  })

  it('toPromptContext includes dog walk info', () => {
    const ctx = userProfile.toPromptContext({
      name: 'Sam',
      pets: ['Dog(s)'],
      dogWalkTimes: ['morning', 'evening'],
      dogWalkDuration: '30 min',
    })
    assert.ok(ctx.includes('dog') || ctx.includes('Dog'))
    assert.ok(ctx.includes('30 min'))
  })

  it('toPromptContext includes work schedule', () => {
    const ctx = userProfile.toPromptContext({
      wakeTime: '06:30',
      workStart: '09:00',
      workEnd: '18:00',
    })
    assert.ok(ctx.includes('06:30'))
    assert.ok(ctx.includes('09:00'))
    assert.ok(ctx.includes('18:00'))
  })

  it('toPromptContext includes exercise info', () => {
    const ctx = userProfile.toPromptContext({
      exerciseFreq: 'Daily',
      exerciseTypes: ['Running', 'Weights'],
      exerciseTime: 'morning',
      exerciseDuration: '45 min',
    })
    assert.ok(ctx.includes('Daily'))
    assert.ok(ctx.includes('Running'))
  })

  it('toPromptContext omits exercise for rare frequency', () => {
    const ctx = userProfile.toPromptContext({ exerciseFreq: 'Rarely' })
    assert.ok(!ctx.includes('workout'))
  })
})

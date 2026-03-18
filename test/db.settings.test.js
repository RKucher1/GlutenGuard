'use strict'
const { describe, it, before, after } = require('node:test')
const assert = require('node:assert')
const { setup, teardown } = require('./helpers/testDb')

describe('settingsDb', () => {
  let settingsDb

  before(() => {
    const mods = setup()
    settingsDb = mods.settingsDb
  })

  after(() => teardown())

  it('get returns null for missing key', () => {
    assert.strictEqual(settingsDb.get('nonexistent_key'), null)
  })

  it('set and get round-trips a value', () => {
    settingsDb.set('test_key', 'hello')
    assert.strictEqual(settingsDb.get('test_key'), 'hello')
  })

  it('set converts numbers to strings', () => {
    settingsDb.set('num_key', 42)
    assert.strictEqual(settingsDb.get('num_key'), '42')
  })

  it('set overwrites existing value', () => {
    settingsDb.set('overwrite_key', 'first')
    settingsDb.set('overwrite_key', 'second')
    assert.strictEqual(settingsDb.get('overwrite_key'), 'second')
  })

  it('getAll returns array of key-value rows', () => {
    const all = settingsDb.getAll()
    assert.ok(Array.isArray(all))
    assert.ok(all.length > 0)
    const keys = all.map(r => r.key)
    assert.ok(keys.includes('notifications_enabled'))
    assert.ok(keys.includes('inactivity_threshold_mins'))
  })

  it('seeded defaults are present', () => {
    assert.strictEqual(settingsDb.get('notifications_enabled'), 'true')
    assert.strictEqual(settingsDb.get('ai_mode'), 'cloud')
    assert.strictEqual(settingsDb.get('theme'), 'dark')
  })
})

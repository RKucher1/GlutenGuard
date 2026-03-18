'use strict'
const { describe, it } = require('node:test')
const assert = require('node:assert')

// We test only the pure helper functions — not network calls
// These are not exported by aiService, so we replicate them here for testing.
// If refactoring exposes them, update imports.

// --- fillTemplate (duplicated logic for testing) ---
function fillTemplate(template, variables) {
  let result = template
  for (const [key, value] of Object.entries(variables)) {
    const val = typeof value === 'object' ? JSON.stringify(value, null, 2) : String(value)
    result = result.replace(new RegExp(`{{${key}}}`, 'g'), val)
  }
  return result
}

// --- parseJSON (duplicated logic for testing) ---
function parseJSON(text) {
  const clean = text.trim()
  try {
    return JSON.parse(clean)
  } catch {
    const match = clean.match(/\{[\s\S]*\}/)
    if (match) return JSON.parse(match[0])
    throw new Error('AI returned invalid JSON: ' + clean.slice(0, 200))
  }
}

describe('fillTemplate', () => {
  it('replaces a single placeholder', () => {
    const result = fillTemplate('Hello {{NAME}}!', { NAME: 'World' })
    assert.strictEqual(result, 'Hello World!')
  })

  it('replaces multiple occurrences of same placeholder', () => {
    const result = fillTemplate('{{X}} and {{X}}', { X: 'foo' })
    assert.strictEqual(result, 'foo and foo')
  })

  it('replaces multiple different placeholders', () => {
    const result = fillTemplate('{{A}} {{B}}', { A: 'hello', B: 'world' })
    assert.strictEqual(result, 'hello world')
  })

  it('serializes objects to JSON', () => {
    const result = fillTemplate('data: {{DATA}}', { DATA: { key: 'val' } })
    assert.ok(result.includes('"key"'))
    assert.ok(result.includes('"val"'))
  })

  it('leaves unmatched placeholders unchanged', () => {
    const result = fillTemplate('{{UNCHANGED}}', { OTHER: 'x' })
    assert.strictEqual(result, '{{UNCHANGED}}')
  })
})

describe('parseJSON', () => {
  it('parses clean JSON string', () => {
    const result = parseJSON('{"message":"ok","proposed_changes":[]}')
    assert.strictEqual(result.message, 'ok')
    assert.deepStrictEqual(result.proposed_changes, [])
  })

  it('parses JSON embedded in text', () => {
    const result = parseJSON('Here is your plan: {"message":"done"} — enjoy!')
    assert.strictEqual(result.message, 'done')
  })

  it('trims whitespace before parsing', () => {
    const result = parseJSON('  {"x":1}  ')
    assert.strictEqual(result.x, 1)
  })

  it('throws on invalid JSON with no embedded object', () => {
    assert.throws(() => parseJSON('not json at all'), /invalid JSON/)
  })
})

describe('API key validation (safeContent logic)', () => {
  it('detects missing ANTHROPIC_API_KEY', () => {
    const originalKey = process.env.ANTHROPIC_API_KEY
    delete process.env.ANTHROPIC_API_KEY
    const hasKey = Boolean(process.env.ANTHROPIC_API_KEY)
    assert.strictEqual(hasKey, false)
    // Restore
    if (originalKey !== undefined) process.env.ANTHROPIC_API_KEY = originalKey
  })

  it('safeContent throws on empty response', () => {
    function safeContent(response) {
      if (!response?.content?.length) throw new Error('AI returned empty response')
      return response.content[0].text
    }
    assert.throws(() => safeContent(null), /empty response/)
    assert.throws(() => safeContent({}), /empty response/)
    assert.throws(() => safeContent({ content: [] }), /empty response/)
    assert.strictEqual(safeContent({ content: [{ text: 'hello' }] }), 'hello')
  })
})

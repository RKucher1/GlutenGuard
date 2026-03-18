import { describe, it } from 'node:test'
import assert from 'node:assert'
import { CATEGORY_COLORS, getCategoryColor, STATUS_STYLES } from '../src/renderer/utils/colors.js'

describe('CATEGORY_COLORS', () => {
  it('has all expected categories', () => {
    for (const cat of ['code', 'content', 'upload', 'flex', 'break']) {
      assert.ok(CATEGORY_COLORS[cat], `missing category: ${cat}`)
    }
  })

  it('each category has bg, border, text, label', () => {
    for (const [cat, val] of Object.entries(CATEGORY_COLORS)) {
      assert.ok(val.bg, `${cat} missing bg`)
      assert.ok(val.border, `${cat} missing border`)
      assert.ok(val.text, `${cat} missing text`)
      assert.ok(val.label, `${cat} missing label`)
    }
  })
})

describe('getCategoryColor', () => {
  it('returns correct color for known category', () => {
    const c = getCategoryColor('code')
    assert.strictEqual(c.border, '#6B9CC4')
  })

  it('falls back to break for unknown category', () => {
    const c = getCategoryColor('nonexistent')
    assert.deepStrictEqual(c, CATEGORY_COLORS.break)
  })

  it('returns teal border for content', () => {
    const c = getCategoryColor('content')
    assert.strictEqual(c.border, '#4CB8CC')
  })
})

describe('STATUS_STYLES', () => {
  it('has all four statuses', () => {
    for (const s of ['pending', 'done', 'partial', 'skipped']) {
      assert.ok(STATUS_STYLES[s], `missing status: ${s}`)
    }
  })

  it('done has checkmark icon', () => {
    assert.strictEqual(STATUS_STYLES.done.icon, '✓')
  })

  it('skipped has lowest opacity', () => {
    assert.ok(STATUS_STYLES.skipped.opacity < STATUS_STYLES.partial.opacity)
  })
})

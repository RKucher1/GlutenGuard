const fs = require('fs')
const path = require('path')

function getUserProfile() {
  try {
    const userProfile = require('../db/userProfile')
    const profile = userProfile.get()
    return userProfile.toPromptContext(profile)
  } catch {
    return 'No personal profile provided.'
  }
}

function loadPrompt(name) {
  const promptPath = path.join(__dirname, '../prompts', `${name}.md`)
  return fs.readFileSync(promptPath, 'utf8')
}

function fillTemplate(template, variables) {
  let result = template
  for (const [key, value] of Object.entries(variables)) {
    const val = typeof value === 'object' ? JSON.stringify(value, null, 2) : String(value)
    result = result.replace(new RegExp(`{{${key}}}`, 'g'), val)
  }
  return result
}

function parseJSON(text) {
  const clean = text.trim()
  try {
    return JSON.parse(clean)
  } catch {
    // Try to extract JSON from response
    const match = clean.match(/\{[\s\S]*\}/)
    if (match) return JSON.parse(match[0])
    throw new Error('AI returned invalid JSON: ' + clean.slice(0, 200))
  }
}

async function getClient() {
  if (!process.env.ANTHROPIC_API_KEY) {
    throw new Error('ANTHROPIC_API_KEY is not set. Add it to your .env file at the project root.')
  }
  const Anthropic = require('@anthropic-ai/sdk')
  return new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY })
}

function safeContent(response) {
  if (!response?.content?.length) throw new Error('AI returned empty response')
  return response.content[0].text
}

async function replanDay(currentSchedule, currentTime, completedBlocks) {
  const client = await getClient()
  const template = loadPrompt('replan_day')
  const prompt = fillTemplate(template, {
    CURRENT_SCHEDULE: currentSchedule,
    CURRENT_TIME: currentTime,
    COMPLETED_BLOCKS: completedBlocks,
    USER_PROFILE: getUserProfile(),
  })
  const response = await client.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 1000,
    messages: [{ role: 'user', content: prompt }],
  })
  return parseJSON(safeContent(response))
}

async function planWeek(scheduleTemplate, existingMeetings, userRequest) {
  const client = await getClient()
  const template = loadPrompt('plan_week')
  const prompt = fillTemplate(template, {
    SCHEDULE_TEMPLATE: scheduleTemplate,
    EXISTING_MEETINGS: existingMeetings,
    USER_REQUEST: userRequest,
    USER_PROFILE: getUserProfile(),
  })
  const response = await client.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 1000,
    messages: [{ role: 'user', content: prompt }],
  })
  return parseJSON(safeContent(response))
}

async function chat(todaySchedule, weekMeetings, userMessage, history, completedBlocks, learningContext) {
  const client = await getClient()
  const template = loadPrompt('chat')
  const today = new Date().toISOString().slice(0, 10)
  const currentTime = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false })
  const systemPrompt = fillTemplate(template, {
    TODAY: today,
    CURRENT_TIME: currentTime,
    CURRENT_SCHEDULE: todaySchedule,
    WEEK_MEETINGS: weekMeetings,
    COMPLETED_BLOCKS: completedBlocks || [],
    USER_PROFILE: getUserProfile(),
    LEARNING_CONTEXT: learningContext || 'No learning data yet.',
  })

  const messages = [
    ...(history || []),
    { role: 'user', content: userMessage },
  ]

  const response = await client.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 1000,
    system: systemPrompt,
    messages,
  })
  return parseJSON(safeContent(response))
}

async function morningBriefing(userFocus, scheduleTemplate, gcalEvents, completionHistory, learningContext) {
  const client = await getClient()
  const template = loadPrompt('morning_briefing')
  const today = new Date().toISOString().slice(0, 10)
  const dayOfWeek = new Date().toLocaleDateString('en-US', { weekday: 'long' })
  const prompt = fillTemplate(template, {
    USER_FOCUS: userFocus,
    TODAY: today,
    DAY_OF_WEEK: dayOfWeek,
    USER_PROFILE: getUserProfile(),
    SCHEDULE_TEMPLATE: scheduleTemplate,
    GCAL_EVENTS: gcalEvents || [],
    COMPLETION_HISTORY: completionHistory || [],
    LEARNING_CONTEXT: learningContext || 'No learning data yet.',
  })
  const response = await client.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 1500,
    messages: [{ role: 'user', content: prompt }],
  })
  return parseJSON(safeContent(response))
}

module.exports = { replanDay, planWeek, chat, morningBriefing }

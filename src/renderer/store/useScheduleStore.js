import { create } from 'zustand'
import { todayString } from '../utils/time'

function addDays(dateStr, days) {
  const d = new Date(dateStr + 'T12:00:00')
  d.setDate(d.getDate() + days)
  return d.toISOString().slice(0, 10)
}

function skipWeekendForward(dateStr) {
  const d = new Date(dateStr + 'T12:00:00')
  const day = d.getDay()
  if (day === 6) return addDays(dateStr, 2)
  if (day === 0) return addDays(dateStr, 1)
  return dateStr
}

function skipWeekendBackward(dateStr) {
  const d = new Date(dateStr + 'T12:00:00')
  const day = d.getDay()
  if (day === 6) return addDays(dateStr, -1)
  if (day === 0) return addDays(dateStr, -2)
  return dateStr
}

const useScheduleStore = create((set, get) => ({
  selectedDate: todayString(),
  blocks: [],
  isLoading: false,
  error: null,

  setDate: async (date) => {
    set({ selectedDate: date, isLoading: true, error: null })
    try {
      const response = await window.electronAPI.invoke('blocks:getByDate', { date })
      if (response.error) {
        set({ error: response.error, isLoading: false })
      } else {
        set({ blocks: response.data, isLoading: false })
      }
    } catch (err) {
      set({ error: err.message, isLoading: false })
    }
  },

  setBlockStatus: async (id, status, note = '') => {
    try {
      const response = await window.electronAPI.invoke('blocks:updateStatus', { id, status, note })
      if (response.error) {
        set({ error: response.error })
      } else {
        set(state => ({
          blocks: state.blocks.map(b =>
            b.id === id ? { ...b, status, completion_note: note } : b
          )
        }))
      }
    } catch (err) {
      set({ error: err.message })
    }
  },

  loadToday: () => {
    get().setDate(todayString())
  },

  goNextDay: () => {
    const next = skipWeekendForward(addDays(get().selectedDate, 1))
    get().setDate(next)
  },

  goPrevDay: () => {
    const prev = skipWeekendBackward(addDays(get().selectedDate, -1))
    get().setDate(prev)
  },
}))

export default useScheduleStore

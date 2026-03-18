// Category colour map — aligned with DayForge logo palette
// bg: card background  |  border: left-edge accent  |  text: label/icon colour
export const CATEGORY_COLORS = {
  code:    { bg: '#0E2238', border: '#6B9CC4', text: '#8AB3D4', label: 'Deep Focus' },  // steel blue
  content: { bg: '#0E2218', border: '#4CB8CC', text: '#6DCADB', label: 'Content'    },  // teal
  upload:  { bg: '#1A1228', border: '#C87941', text: '#D4935A', label: 'Upload'     },  // copper
  flex:    { bg: '#221A0E', border: '#D4A857', text: '#E0BC78', label: 'Flex'       },  // gold
  break:   { bg: '#111C2A', border: '#3D5068', text: '#7A8FA6', label: 'Break'      },  // muted
}

export function getCategoryColor(category) {
  return CATEGORY_COLORS[category] ?? CATEGORY_COLORS.break
}

export const STATUS_STYLES = {
  pending: { opacity: 1,    icon: null, label: 'Pending' },
  done:    { opacity: 0.6,  icon: '✓',  label: 'Done'    },
  partial: { opacity: 0.8,  icon: '◐',  label: 'Partial' },
  skipped: { opacity: 0.35, icon: '✕',  label: 'Skipped' },
}

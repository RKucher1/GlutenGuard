export const CATEGORY_COLORS = {
  code:    { bg: '#0d2a1f', border: '#1D9E75', text: '#4ade80', label: 'Deep focus' },
  content: { bg: '#0d1f3c', border: '#378ADD', text: '#60a5fa', label: 'Content' },
  upload:  { bg: '#1a0d3c', border: '#7F77DD', text: '#a78bfa', label: 'Upload' },
  flex:    { bg: '#2a1a0d', border: '#BA7517', text: '#fb923c', label: 'Flex' },
  break:   { bg: '#1a1a1a', border: '#374151', text: '#9ca3af', label: 'Break' },
}

export function getCategoryColor(category) {
  return CATEGORY_COLORS[category] ?? CATEGORY_COLORS.break
}

export const STATUS_STYLES = {
  pending: { opacity: 1,    icon: null, label: 'Pending' },
  done:    { opacity: 0.6,  icon: '✓',  label: 'Done' },
  partial: { opacity: 0.8,  icon: '◐',  label: 'Partial' },
  skipped: { opacity: 0.35, icon: '✕',  label: 'Skipped' },
}

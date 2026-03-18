export default {
  darkMode: 'class',
  content: ['./src/renderer/**/*.{jsx,html}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#0A1628',
          900: '#0d1f3c',
          800: '#112244',
          700: '#1a3a6b',
          600: '#1e4580',
        },
        cyan: {
          400: '#00E5FF',
          300: '#33ecff',
        },
        red: { alert: '#FF2D2D' },
        orange: { warn: '#FF6B35' },
      }
    }
  },
  plugins: []
}

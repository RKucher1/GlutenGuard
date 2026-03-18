export default {
  darkMode: 'class',
  content: ['./src/renderer/**/*.{jsx,html}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#0A1628',
          900: '#0D1B2A',
          800: '#112038',
          700: '#1A2F4A',
          600: '#1E3A5F',
        },
        // Primary teal accent — matches "Forged" text in logo
        teal: {
          400: '#4CB8CC',
          300: '#6DCADB',
          200: '#9ADCE8',
        },
        // Warm copper/bronze — compass rose in logo
        copper: {
          500: '#C87941',
          400: '#D4935A',
          300: '#E0AD7A',
        },
        // Gold highlights — compass needle glow
        gold: {
          500: '#D4A857',
          400: '#E0BC78',
        },
        // Steel blue — crescent / circuit elements
        steel: {
          500: '#6B9CC4',
          400: '#8AB3D4',
        },
        red:    { alert: '#FF3D3D' },
        orange: { warn: '#FF6B35' },
      }
    }
  },
  plugins: []
}

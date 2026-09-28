/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Brand colors
        'oxide-black': '#0F1113',
        'forged-white': '#F4F5F7',
        'rust-red': '#9B2C2C',
        'steel-gray': '#5F6670',
        'signal-amber': '#C47A2C',
        'border': '#1F2328',
        'border-subtle': '#2D3139',
        // Semantic aliases
        'primary': '#9B2C2C',
        'primary-light': '#C53030',
        'accent': '#9B2C2C',
        'accent-hover': '#7F2424',
        'danger': '#7F1D1D',
        'danger-hover': '#991B1B',
        'success': '#22c55e',
        'warning': '#C47A2C',
      },
      borderRadius: {
        'sm': '4px',
        'md': '6px',
        DEFAULT: '6px',
      },
      fontFamily: {
        'sans': ['Inter Variable', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

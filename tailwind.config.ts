import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        // Paleta de marca Vitamed (derivada del logo)
        vitamed: {
          50: '#effafc',
          100: '#d7f2f7',
          200: '#b3e9f0', // celeste claro del acento del logo
          300: '#7fd8e4',
          400: '#3fbcce',
          500: '#1b9aaf', // turquesa principal (cruz del logo)
          600: '#157f92',
          700: '#166578',
          800: '#175264',
          900: '#16455a', // azul petróleo del wordmark "Vitamed"
          950: '#0f2f3f',
        },
      },
      fontFamily: {
        brand: ['var(--font-brand)', 'sans-serif'],
      },
    },
  },
  plugins: [],
};

export default config;

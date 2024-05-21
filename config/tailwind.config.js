const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: {
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
      './app/javascript/**/*.vue',
      './app/assets/stylesheets/**/*.css',
      // Add other directories as needed
    ],
    safelist: [
      'bg-black',
      'dark:bg-white',
      'relative',
      'left-0',
      'top-0',
      'my-1',
      'block',
      'h-0.5',
      'w-0',
      'rounded-sm',
      'delay-[0]',
      'duration-200',
      'ease-in-out',
      '!w-full',
      'delay-300',
    ],
  },
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  darkMode: 'class',
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}

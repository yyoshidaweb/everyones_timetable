/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/assets/stylesheets/**/*.css',
    ],
    theme: {
        extend: {},
    },
    plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/aspect-ratio'),
        require('@tailwindcss/typography'),
    ],
} 
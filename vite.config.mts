import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  css: {
    preprocessorOptions: {
      sass: {
        // Bulma 1.x still uses the legacy `if()` function internally. Until
        // upstream migrates to the modern `if` syntax, silence the otherwise
        // very noisy deprecation warnings emitted from inside node_modules.
        silenceDeprecations: ['if-function'],
      },
      scss: {
        silenceDeprecations: ['if-function'],
      },
    },
  },
})

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['icons/pantri-icon.svg'],
      manifest: {
        name: 'Pantri',
        short_name: 'Pantri',
        description: 'Local-first pantry list and grocery texting helper.',
        theme_color: '#14532d',
        background_color: '#f7f4ef',
        display: 'standalone',
        start_url: '/',
        icons: [
          {
            src: 'icons/pantri-icon.svg',
            sizes: 'any',
            type: 'image/svg+xml'
          }
        ]
      },
      srcDir: 'src',
      filename: 'sw.ts',
      strategies: 'injectManifest'
    })
  ],
  resolve: {
    alias: {
      '@': '/src'
    }
  },
  test: {
    environment: 'jsdom',
    setupFiles: './vitest.setup.ts'
  }
});

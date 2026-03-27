import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'LcCore',
  description: 'Documentation du framework LcCore - LastCountry RedM',
  base: '/LcCore-docs/',

  themeConfig: {
    nav: [
      { text: 'Accueil', link: '/' },
      { text: 'Server', link: '/server' },
      { text: 'Client', link: '/client' },
      { text: 'Menu', link: '/menu' },
    ],

    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'Accueil', link: '/' },
          { text: 'Base de donnees', link: '/database' },
        ]
      },
      {
        text: 'API Server',
        items: [
          { text: 'Player & Core', link: '/server' },
          { text: 'Economie & Taxes', link: '/economy' },
          { text: 'Evenements', link: '/events' },
        ]
      },
      {
        text: 'API Client',
        items: [
          { text: 'Callbacks, State, KVP', link: '/client' },
          { text: 'Menu', link: '/menu' },
        ]
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/DeVerino-DVR/LcCore-docs' }
    ],

    search: {
      provider: 'local'
    },

    footer: {
      message: 'LastCountry Framework',
    }
  }
})

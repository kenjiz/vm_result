import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'vm_result',
  tagline: 'A minimal, production-grade MVVM ViewModel contract for Flutter',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://kenjiz.github.io',
  baseUrl: '/vm_result/',

  organizationName: 'kenjiz',
  projectName: 'vm_result',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/kenjiz/vm_result/tree/main/website/',
        },
        blog: false, // Disabled to focus purely on API documentation
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'vm_result',
      logo: {
        alt: 'vm_result Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://github.com/kenjiz/vm_result',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Introduction',
              to: '/docs/intro',
            },
            {
              label: 'Getting Started',
              to: '/docs/getting-started',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'GitHub Issues',
              href: 'https://github.com/kenjiz/vm_result/issues',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Enrique Chua. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart'], // Support Dart syntax highlighting
    },
  } satisfies Preset.ThemeConfig,
};

export default config;

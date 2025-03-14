return {
  {
    'saghen/blink.compat',
    version = '*',
    opts = {},
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets', 'giuxtaposition/blink-cmp-copilot' },
    version = '*',
    opts = require('config.blink-conf'),
  },
}

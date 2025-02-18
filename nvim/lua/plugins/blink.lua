return {
  {
    'saghen/blink.compat',
    version = '*',
    opts = {},
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    opts = require('config.blink-conf'),
  },
}

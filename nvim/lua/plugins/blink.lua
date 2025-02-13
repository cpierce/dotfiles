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
    config = function(_, opts)
      require('blink.cmp').setup(opts)
    end,
  },
}

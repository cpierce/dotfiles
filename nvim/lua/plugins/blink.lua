return {
  {
    'saghen/blink.compat',
    version = '*',
    lazy = true,
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    config = function()
      require('blink.cmp').setup(require('config.blink-conf'))
    end,
  },
}

return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    opts = require('config.oil-conf'),
    lazy = false,
    keys = {
      { '-', '<cmd>Oil<cr>', silent = true, desc = 'Open (oil)' },
    },
  },
}

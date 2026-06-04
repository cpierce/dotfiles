return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    event = 'VeryLazy', -- Load just after startup
    opts = require('config.lualine-conf'), -- Loads external configuration
  },
}

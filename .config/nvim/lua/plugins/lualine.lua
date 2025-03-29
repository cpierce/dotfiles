return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    lazy = false, -- Load immediately
    opts = require('config.lualine-conf'), -- Loads external configuration
  },
}

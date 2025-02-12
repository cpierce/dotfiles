return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'echasnovski/mini.icons' },
    lazy = false, -- Load immediately
    opts = require('config.lualine-conf'), -- Loads external configuration
  },
}

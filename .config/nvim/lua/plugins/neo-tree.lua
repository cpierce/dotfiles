return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  opts = require('config.neo-tree-conf'),
  keys = {
    {
      '<leader>fe',
      ':Neotree toggle<cr>',
      noremap = true,
      silent = true,
      desc = 'Toggle Explorer',
    },
  },
}

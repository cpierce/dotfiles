return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = require('config.gitsigns'),
  },
}

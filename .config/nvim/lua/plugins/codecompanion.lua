return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions', 'CodeCompanionCmd' },
    opts = require('config.codecompanion-conf'),
    keys = {
      { '<leader>aa', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, noremap = true, silent = true, desc = 'Actions (CodeCompanion)' },
      { '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, noremap = true, silent = true, desc = 'Toggle Chat (CodeCompanion)' },
      { '<leader>ad', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', noremap = true, silent = true, desc = 'Add Selection to Chat (CodeCompanion)' },
    },
  },
}

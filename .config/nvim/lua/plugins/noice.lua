return {
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
      'ibhagwan/fzf-lua',
    },
    opts = require('config.noice-conf'),
  },
}

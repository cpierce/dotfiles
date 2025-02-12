return {
  {
    'stevearc/conform.nvim',
    version = false, -- Use the latest version
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'nvim-lua/plenary.nvim' },
      { 'williamboman/mason.nvim' },
      { 'williambowan/mason-lspconfig.nvim' },
    },
    opts = require('config.conform-conf'),
  },
}

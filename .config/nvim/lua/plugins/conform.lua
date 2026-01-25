return {
  {
    'stevearc/conform.nvim',
    version = false, -- Use the latest version
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'nvim-lua/plenary.nvim' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    opts = require('config.conform-conf'),
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        noremap = true,
        silent = true,
        desc = 'Format File',
      },
    },
  },
}

return {
  {
    'stevearc/conform.nvim',
    version = false, -- Use the latest version
    dependencies = {
      { 'williamboman/mason.nvim' },
    },
    opts = require('config.conform-conf'),
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        noremap = true,
        silent = true,
        desc = 'Format File',
      },
    },
  },
}

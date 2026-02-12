return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup(require('config.mason-conf'))
    end,
    keys = {
      { '<leader>lm', '<cmd>Mason<cr>', mode = 'n', noremap = true, silent = true, desc = 'Open (mason)' },
      { '<leader>ly', '<cmd>MasonUpdate<cr>', mode = 'n', noremap = true, silent = true, desc = 'Update (mason)' },
    },
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'saghen/blink.cmp',
      'mfussenegger/nvim-dap',
      'jay-babu/mason-nvim-dap.nvim',
      'b0o/schemastore.nvim',
    },
    config = function()
      require('mason-lspconfig').setup(require('config.mason-lspconfig-conf'))
      require('lsp')
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup(require('config.mason-tool-installer-conf'))
    end,
  },
}

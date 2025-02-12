return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'echasnovski/mini.icons' },
    config = function()
      require('mason-lspconfig').setup(require('config.mason-conf'))
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      local lspconfig = require('lspconfig')
      local config = require('config.lspconfig-conf')

      lspconfig.lua_ls.setup(config)
      lspconfig['lua_ls'].setup(require('config.lsp.lua_ls-conf'))
    end,
  },
}

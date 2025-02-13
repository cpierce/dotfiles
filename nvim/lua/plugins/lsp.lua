return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup(require('config.mason-conf'))
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    config = function()
      require('mason-lspconfig').setup(require('config.mason-lspconfig-conf'))
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'simrat39/rust-tools.nvim',
        dependencies = { 'neovim/nvim-lspconfig' },
        config = function()
          require('rust-tools').setup({})
        end,
      },
      'williamboman/mason-lspconfig.nvim',
    },
    opts = require('config.lspconfig-conf'),
    config = function()
      local lspconfig = require('lspconfig')

      for _, server in ipairs({ 'lua_ls', 'intelephense', 'rust_analyzer' }) do
        lspconfig[server].setup(require('config.lsp.' .. server .. '-conf'))
      end
    end,
  },
}

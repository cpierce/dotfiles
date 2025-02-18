return {
  {
    'williamboman/mason.nvim',
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
        'b0o/schemastore.nvim',
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

      for _, server in ipairs({
        'cssls',
        'html',
        'intelephense',
        'jsonls',
        'lua_ls',
        'rust_analyzer',
        'yamlls',
      }) do
        lspconfig[server].setup(require('config.lsp.' .. server .. '-conf'))
      end
    end,
  },
}

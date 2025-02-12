return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup(require('config.mason'))
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      local lspconfig = require('lspconfig')

      -- Setup installed LSP servers
      local servers = { 'lua_ls', 'ts_ls' }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({})
      end
    end,
  },
}

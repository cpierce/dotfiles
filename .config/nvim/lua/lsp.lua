-- LSP Configuration
--
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Servers that need custom settings
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
  capabilities = capabilities,
})

vim.lsp.config('cssls', {
  root_markers = { '.git', '.stylelintrc', '.stylelintignore.json' },
  capabilities = capabilities,
})

vim.lsp.config('intelephense', {
  root_markers = { 'composer.json', 'phpunit.xml', '.git' },
  capabilities = capabilities,
})

vim.lsp.config('yamlls', {
  root_markers = { '.github', 'docker-compose.yaml' },
  capabilities = capabilities,
})

-- Servers with default settings just need capabilities
for _, server in ipairs({ 'bashls', 'html', 'jsonls' }) do
  vim.lsp.config(server, {
    capabilities = capabilities,
  })
end

-- Enable all servers (rust_analyzer is managed by rustaceanvim)
vim.lsp.enable({ 'bashls', 'cssls', 'html', 'intelephense', 'jsonls', 'lua_ls', 'yamlls' })

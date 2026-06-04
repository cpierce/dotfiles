-- LSP Configuration
--
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Apply blink's completion capabilities to every server (0.11 '*' fallback),
-- so individual configs below only need their server-specific bits.
vim.lsp.config('*', {
  capabilities = capabilities,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

vim.lsp.config('cssls', {
  root_markers = { '.git', '.stylelintrc', '.stylelintignore.json' },
})

vim.lsp.config('intelephense', {
  root_markers = { 'composer.json', 'phpunit.xml', '.git' },
})

-- jsonls/yamlls get their schemas from SchemaStore (package.json, tsconfig,
-- GitHub Actions, docker-compose, etc.).
vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config('yamlls', {
  root_markers = { '.github', 'docker-compose.yaml' },
  settings = {
    yaml = {
      -- Disable the built-in store so it doesn't fight SchemaStore.
      schemaStore = { enable = false, url = '' },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
})

-- bashls and html need no extra settings (capabilities come from '*').

-- Enable all servers (rust_analyzer is managed by rustaceanvim)
vim.lsp.enable({ 'bashls', 'cssls', 'html', 'intelephense', 'jsonls', 'lua_ls', 'yamlls' })

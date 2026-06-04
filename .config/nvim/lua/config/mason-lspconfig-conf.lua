return {
  ensure_installed = {
    'bashls',
    'cssls',
    'html',
    'intelephense',
    'jsonls',
    'lua_ls',
    'yamlls',
  },
  -- Servers are enabled explicitly in lua/lsp.lua (with custom settings), so
  -- don't let mason-lspconfig auto-enable everything it finds installed.
  -- (`ensure_installed` above still drives installation in v2.)
  automatic_enable = false,
}

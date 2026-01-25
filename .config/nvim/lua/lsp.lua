vim.lsp.config = {
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    root_markers = { '.git' },
    filetypes = { 'sh', 'bash' },
  },
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    root_markers = { '.git', '.stylelintrc', '.stylelintignore.json' },
    filetypes = { 'css', 'scss', 'less' },
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    root_markers = { '.git', 'package.json' },
    filetypes = { 'html' },
  },
  intelephense = {
    cmd = { 'intelephense', '--stdio' },
    root_markers = { 'composer.json', 'phpunit.xml', '.git' },
    filetypes = { 'php' },
  },
  jsonls = {
    cmd = { 'vscode-json-languageserver', '--stdio' },
    filetypes = { 'json' },
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    root_markers = { 'init.lua', '.git' },
    filetypes = { 'lua' },
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    root_markers = { '.github', 'docker-compose.yaml' },
    filetypes = { 'yaml' },
  },
}

local capabilities = require('blink.cmp').get_lsp_capabilities()
for _, config in pairs(vim.lsp.config) do
  config.capabilities = vim.tbl_deep_extend('force', config.capabilities or {}, capabilities)
end

-- Iterate over the lsp.config for each filetype specified above.
for server_name in pairs(vim.lsp.config) do
  vim.lsp.enable(server_name)
end

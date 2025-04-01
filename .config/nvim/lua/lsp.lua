vim.lsp.config = {
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
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    root_markers = { '.github', 'docker-compose.yaml' },
    filetypes = { 'yaml' },
  },
}

-- Iterate over the lsp.config for each filetype specified above.
for server_name in pairs(vim.lsp.config) do
  vim.lsp.enable(server_name)
end

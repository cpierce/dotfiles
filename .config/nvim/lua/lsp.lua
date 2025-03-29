local api = vim.api

-- Define server configurations
local servers = {
  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html' },
  },
  intelephense = {
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
  },
  jsonls = {
    cmd = { 'vscode-json-languageserver', '--stdio' },
    filetypes = { 'json' },
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
  },
  rust_analyzer = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml' },
  },
}

-- A common root directory detection function
local function default_root_dir(fname)
  -- This is a simple example; you might want to use vim.fs.find() for more robust detection.
  return vim.fs.dirname(fname) or vim.loop.cwd()
end

-- Iterate over the server table and create autocommands for each filetype.
for server_name, config in pairs(servers) do
  for _, ft in ipairs(config.filetypes) do
    api.nvim_create_autocmd('FileType', {
      pattern = ft,
      callback = function(args)
        local bufnr = args.buf
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root_dir = default_root_dir(fname)

        -- Check if this server is already attached to the buffer.
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
          if client.name == server_name then
            return -- Already attached; do nothing.
          end
        end

        -- Start the server.
        vim.lsp.start(vim.tbl_extend('force', {
          name = server_name,
          cmd = config.cmd,
          root_dir = root_dir,
          filetypes = config.filetypes,
          on_attach = function(client, bufnr)
            -- Optional: set up keymaps or additional settings here.
            print('LSP ' .. server_name .. ' attached to buffer ' .. bufnr)
          end,
        }, require('config.lsp.' .. server_name .. '-conf')))
      end,
    })
  end
end

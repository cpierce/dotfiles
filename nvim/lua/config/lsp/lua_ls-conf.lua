return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }, -- Tell LuaLS `vim` is global
      },
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true), -- Recognizes Neovim API
        checkThirdParty = false, -- Optional: Prevents unnecessary warnings
      },
      telemetry = { enable = false },
    },
  },
}

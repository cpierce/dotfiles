return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'nvim_bufferline', 'Snacks', 'MiniIcons' }, -- Tell LuaLS `vim` is global
      },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = 'Disable',
        semicolon = 'Disable',
        arrayIndex = 'Disable',
      },
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = {
          '${3rd}/luv/library',
          vim.api.nvim_get_runtime_file('', true),
        },
        checkThirdParty = false, -- Optional: Prevents unnecessary warnings
      },
      telemetry = { enable = false },
    },
  },
}

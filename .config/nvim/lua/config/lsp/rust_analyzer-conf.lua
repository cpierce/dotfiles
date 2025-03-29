local rt = require('rust-tools')
return {
  server = {
    on_attach = function(_, bufnr)
      -- Keybindings for Rust actions
      vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr, desc = 'Rust Code Actions' })
    end,
    settings = {
      ['rust-analyzer'] = {
        filetypes = { 'rust' },
        diagnostics = {
          enable = true,
        },
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          command = 'clippy',
        },
      },
    },
  },
}

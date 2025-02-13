return {
  on_attach = function(_, bufnr)
    -- Keybindings for Rust actions
    vim.keymap.set('n', '<C-space>', require('rust-tools').hover_actions.hover_actions, { buffer = bufnr })
    vim.keymap.set('n', '<Leader>ca', require('rust-tools').code_action_group.code_action_group, { buffer = bufnr, desc = 'Rust Code Actions' })
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
}

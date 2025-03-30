return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy
  keys = {
    {
      '<leader>cr',
      '<cmd>RustLsp relatedDiagnostics<cr>',
      noremap = true,
      silent = true,
      desc = 'Rust Diagnostics',
    },
  },
}

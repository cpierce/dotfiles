return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    opts = {},
    lazy = false,
    keys = {
      { '<leader>fo', '<cmd>Oil<cr>', silent = true, desc = 'Open (oil)' },
    },
  },
}

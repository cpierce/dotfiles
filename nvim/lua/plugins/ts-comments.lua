return {
  {
    'folke/ts-comments.nvim',
    keys = {
      { '///', '<cmd>normal gcc<cr>', mode = 'n', silent = true, desc = 'Comment Line' },
      { '<leader>/', '<cmd>normal gcc<cr>', mode = 'n', silent = true, desc = 'Comment' },
      { '<leader>/', ":'<,'>normal gcc<cr>", mode = 'v', silent = true, desc = 'Comment' },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
  },
}

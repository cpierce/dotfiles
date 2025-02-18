return {
  {
    'folke/which-key.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    priority = 10000,
    config = function()
      require('which-key').setup(require('config.which-key-conf'))
    end,
  },
}

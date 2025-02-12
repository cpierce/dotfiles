return {
  {
    'folke/which-key.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    config = function()
      require('which-key').setup(require('config.which-key-conf'))
    end,
  },
}

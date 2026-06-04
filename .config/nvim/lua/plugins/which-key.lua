return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup(require('config.which-key-conf'))
    end,
  },
}

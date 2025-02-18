return {
  {
    'folke/which-key.nvim',
    priority = 1000,
    config = function()
      require('which-key').setup(require('config.which-key-conf'))
    end,
  },
}

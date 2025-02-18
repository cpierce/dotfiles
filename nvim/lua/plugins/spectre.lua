return {
  {
    'nvim-pack/nvim-spectre',
    config = function()
      require('spectre').setup(require('config.spectre-conf'))
    end,
  },
}

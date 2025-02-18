return {
  {
    'echasnovski/mini.ai',
    version = false,
    config = function()
      require('mini.ai').setup(require('config.mini.ai-conf'))
    end,
  },
  {
    'echasnovski/mini.icons',
    version = false,
    config = function()
      require('mini.icons').setup(require('config.mini.icons-conf'))
      require('mini.icons').mock_nvim_web_devicons()
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require('mini.pairs').setup(require('config.mini.pairs-conf'))
    end,
  },
}

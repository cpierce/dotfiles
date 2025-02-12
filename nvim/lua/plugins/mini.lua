return {
  {
    'echasnovski/mini.ai',
    version = false,
    config = function()
      require('mini.ai').setup(require('config.mini.ai-conf'))
    end,
  },
  {
    'echasnovski/mini.comment',
    config = function()
      require('mini.comment').setup(require('config.mini.comment-conf'))
    end,
  },
  {
    'echasnovski/mini.icons',
    version = false,
    config = function()
      require('mini.icons').setup(require('config.mini.icons-conf'))
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require('mini.pairs').setup(require('config.mini.pairs-conf'))
    end,
  },
  {
    'echasnovski/mini.indentscope',
    version = false,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mini.indentscope').setup(require('config.mini.indentscope-conf'))
    end,
  },
}

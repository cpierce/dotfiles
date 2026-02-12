return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    opts = require('config.snacks-conf'),
    config = function(_, opts)
      require('snacks').setup(opts)
    end,
    keys = {
      {
        '<leader>ff',
        function()
          require('snacks').picker.pick('files')
        end,
        mode = 'n',
        silent = true,
        desc = 'Find Files (snacks)',
      },
      {
        '<leader>fg',
        function()
          require('snacks').picker.pick('grep')
        end,
        mode = 'n',
        silent = true,
        desc = 'Grep Files (snacks)',
      },
      {
        '<leader>t',
        function()
          require('snacks').terminal()
        end,
        silent = true,
        desc = 'Terminal (snacks)',
      },
      {
        '<leader>gt',
        function()
          require('snacks').lazygit()
        end,
        silent = true,
        desc = 'Git Toggle (snacks)',
      },
      {
        '<leader>gl',
        function()
          require('snacks').lazygit.log()
        end,
        silent = true,
        desc = 'Git Log (snacks)',
      },
      {
        '<leader>fm',
        function()
          require('snacks').dashboard.open()
        end,
        silent = true,
        desc = 'Display File Menu (snacks)',
      },
      {
        ']]',
        function()
          require('snacks').words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          require('snacks').words.jump(-vim.v.count1)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
    },
  },
}

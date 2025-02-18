return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    opts = require('config.snacks-conf'),
    config = function(_, opts)
      local notify = vim.notify
      require('snacks').setup(opts)
      vim.notify = notify
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
        '<leader>fe',
        function()
          require('snacks').explorer()
        end,
        silent = true,
        desc = 'File Explorer Toggle (snacks)',
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
        ']]',
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
    },
  },
}

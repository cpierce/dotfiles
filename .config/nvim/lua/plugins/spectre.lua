return {
  {
    'nvim-pack/nvim-spectre',
    config = function()
      require('spectre').setup(require('config.spectre-conf'))
    end,
    keys = {
      {
        '<C-f>',
        function()
          require('spectre').toggle()
        end,
        noremap = true,
        silent = true,
        desc = 'Search and Replace (spectre)',
      },
      {
        '<leader>fr',
        function()
          require('spectre').toggle()
        end,
        noremap = true,
        silent = true,
        desc = 'Search and Replace (spectre)',
      },
      {
        '<leader>fw',
        function()
          require('spectre').open_file_search({ select_word = true })
        end,
        noremap = true,
        silent = true,
        desc = 'Search Selected Word (spectre)',
      },
    },
  },
}

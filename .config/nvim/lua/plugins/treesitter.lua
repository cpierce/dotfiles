return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup(require('config.treesitter-conf'))
    end,
    keys = {
      { '<C-space>', desc = 'Increment Selection' },
      { '<bs>', desc = 'Decrement Selection', mode = 'x' },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { ']f', function() require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer') end, desc = 'Next function start' },
      { ']c', function() require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer') end, desc = 'Next class start' },
      { ']a', function() require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.inner') end, desc = 'Next parameter' },
      { ']F', function() require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer') end, desc = 'Next function end' },
      { ']C', function() require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer') end, desc = 'Next class end' },
      { ']A', function() require('nvim-treesitter-textobjects.move').goto_next_end('@parameter.inner') end, desc = 'Next parameter end' },
      { '[f', function() require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer') end, desc = 'Prev function start' },
      { '[c', function() require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer') end, desc = 'Prev class start' },
      { '[a', function() require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.inner') end, desc = 'Prev parameter' },
      { '[F', function() require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer') end, desc = 'Prev function end' },
      { '[C', function() require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer') end, desc = 'Prev class end' },
      { '[A', function() require('nvim-treesitter-textobjects.move').goto_previous_end('@parameter.inner') end, desc = 'Prev parameter end' },
    },
  },
}

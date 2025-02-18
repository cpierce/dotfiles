return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'windwp/nvim-ts-autotag' },
    opts = require('config.treesitter-conf'),
    keys = {
      { '<C-space>', desc = 'Increment Selection' },
      { '<bs>', desc = 'Decrement Selection', mode = 'x' },
    },
  },
}

return {
  preset = 'helix',
  spec = {
    {
      mode = { 'n', 'v' },
      { '<leader><tab>', group = 'tabs' },
      { '<leader>c', group = 'code' },
      { '<leader>d', group = 'debug' },
      { '<leader>f', group = 'file/find' },
      { '<leader>i', group = 'code references' },
      { '<leader>l', group = 'lazy/mason' },
      { '<leader>m', group = 'messages', icon = { icon = '󰚢', color = 'red' } },
      { '<leader>g', group = 'git' },
      { '<leader>gh', group = 'hunks' },
      { '<leader>q', group = 'quit/session' },
      { '<leader>s', group = 'search' },
      { '<leader>u', group = 'ui', icon = { icon = '󰙵 ', color = 'cyan' } },
      { '<leader>x', group = 'diagnostics/quickfix', icon = { icon = '󱖫 ', color = 'green' } },
      { '<leader>y', group = 'clipboard' },
      { '[', group = 'prev' },
      { ']', group = 'next' },
      { 'g', group = 'goto' },
      { 'gs', group = 'surround' },
      { 'z', group = 'fold' },
      {
        '<leader>b',
        group = 'buffer',
        expand = function()
          return require('which-key.extras').expand.buf()
        end,
      },
      {
        '<leader>w',
        group = 'windows',
        proxy = '<c-w>',
        expand = function()
          return require('which-key.extras').expand.win()
        end,
      },
      { 'gx', desc = 'Open with system app' },
    },
  },
}

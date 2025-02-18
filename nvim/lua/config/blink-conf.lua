return {
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      draw = {
        treesitter = { 'lsp' },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = {
      enabled = true,
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    cmdline = {},
  },

  keymap = {
    preset = 'super-tab',
    ['<C-y>'] = { 'select_and_accept' },
  },
}

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
        columns = {
          { 'label', 'label_description', gap = 1 },
        },
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
    default = { 'lsp', 'path', 'buffer' },
    cmdline = {},
  },

  keymap = {
    preset = 'super-tab',
  },
}

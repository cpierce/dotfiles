return {
  appearance = {
    use_nvim_cmp_as_default = false,
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
    default = { 'lsp', 'path', 'buffer' },
    cmdline = {},
  },

  keymap = {
    preset = 'enter',
    ['C-y'] = { 'select_and_accept' },
    ['<Cmd>'] = { 'select_and_accept' },
  },
}

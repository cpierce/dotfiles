return {
  flavour = 'mocha',
  transparent_background = true,
  integrations = {
    blink_cmp = true,
    dashboard = true,
    bufferline = true,
    gitsigns = true,
    lsp_trouble = true,
    mason = true,
    markdown = true,
    mini = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
    neotree = true,
    noice = true,
    notify = true,
    semantic_tokens = true,
    treesitter = true,
    which_key = true,
  },
}

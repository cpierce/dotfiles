return {
  flavour = "mocha", -- Options: latte, frappe, macchiato, mocha
  transparent_background = true,
  integrations = {
    aerial = true,
    alpha = true,
    blink_cmp = true,
    cmp = true,
    dashboard = true,
    bufferline = true,
    flash = true,
    fzf = true,
    gitsigns = true,
    grug_far = true, -- Ensure this is a valid plugin integration
    headlines = true,
    illuminate = true,
    indent_blankline = { enabled = true },
    leap = true,
    lsp_trouble = true,
    mason = true,
    markdown = true,
    mini = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
    navic = { enabled = true, custom_bg = "lualine" },
    neotest = true,
    neotree = true,
    noice = true,
    notify = true,
    semantic_tokens = true,
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  },
  colorscheme = "catppuccin-mocha", -- Define the colorscheme here
}

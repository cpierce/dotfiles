return {
  default_format_opts = {
    timeout_ms = 3000, -- Increased timeout for stability
    async = false, -- Keep synchronous formatting
    quiet = false, -- Do not suppress errors
    lsp_format = 'fallback', -- Keep LSP formatting as fallback
  },

  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    scss = { 'prettier' },
    less = { 'prettier' },
    markdown = { 'prettier' },
    bash = { 'shfmt' },
    sh = { 'shfmt' },
    php = { 'php_cs_fixer' },
  },

  -- Custom formatters and additional settings
  formatters = {
    injected = { options = { ignore_errors = true } },

    shfmt = {
      prepend_args = { '-i', '2', '-ci' },
    },
    php_cs_fixer = {
      prepend_args = { '--using-cache=no' },
    },
  },

  format_on_save = {
    timeout_ms = 3000,
    lsp_fallback = true,
  },
}

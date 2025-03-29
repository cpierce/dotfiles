local icons = require('utils.icons')
return {
  modes = {
    lsp = {
      win = { position = 'right' },
    },
  },
  signs = {
    error = icons.diagnostics.error,
    warning = icons.diagnostics.warn,
    hint = icons.diagnostics.hint,
    information = icons.diagnostics.info,
    other = icons.diagnostics.other,
  },
  use_diagnostic_signs = true, -- Use signs defined in LSP client
}

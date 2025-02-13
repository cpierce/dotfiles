return {
  filetypes = { 'php' },
  init_options = {
    ['language_server_phpstan.enabled'] = true,
    ['langguage_server_psalm'] = true,
  },
  settings = {
    intelephense = {
      completion = { enabled = true },
      diagnostics = { enabled = true },
      index = { enabled = true },
    },
  },
}

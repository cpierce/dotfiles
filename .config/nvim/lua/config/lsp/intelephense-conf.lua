return {
  filetypes = { 'php' },
  settings = {
    intelephense = {
      files = {
        exclude = {
          '**/.git/**',
          '**/node_modules/**',
          '**/vendor/**/{Tests,tests}/**',
          '**/.history/**',
        },
        maxSize = 5000000,
      },
      completion = {
        enabled = true,
      },
      environment = {
        phpVersion = '8.3',
      },
      diagnostics = {
        enabled = true,
        undefinedTypes = false,
        undefinedFunctions = false,
        undefinedConstants = false,
        undefinedClassConstants = false,
        undefinedVariables = true,
      },
    },
  },
}

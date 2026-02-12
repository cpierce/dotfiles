return function()
  local lint = require('lint')

  lint.linters_by_ft = {
    bash = { 'shellcheck' },
    sh = { 'shellcheck' },
    php = { 'php' },
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    rust = { 'clippy' },
    lua = { 'luacheck' },
  }

  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
    callback = function()
      lint.try_lint()
    end,
  })

  lint.try_lint()
end

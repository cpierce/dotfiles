return function()
  local lint = require('lint')

  lint.linters_by_ft = {
    bash = { 'shellcheck' },
    sh = { 'shellcheck' },
    php = { 'php' },
    javascript = { 'eslint_d', 'eslint' },
    typescript = { 'eslint_d', 'eslint' },
    rust = { 'clippy' },
    lua = { 'luacheck' },
  }

  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
    callback = function()
      lint.try_lint()
    end,
  })
end

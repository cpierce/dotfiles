return {
  {
    'mfussenegger/nvim-lint',
    events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    config = require('config.nvim-lint-conf'),
  },
}

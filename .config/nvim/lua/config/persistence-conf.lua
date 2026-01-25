return {
  dir = vim.fn.stdpath('data') .. '/sessions/', -- Store session files
  options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }, -- What to save
}

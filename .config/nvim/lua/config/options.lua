-- Options
--

vim.opt.mouse = "nv"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.cmd([[
  autocmd FileType php setlocal expandtab shiftwidth=4 tabstop=4
]])

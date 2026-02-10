return {
  dir = vim.fn.stdpath('data') .. '/sessions/', -- Store session files
  options = vim.opt.sessionoptions:get(), -- Uses sessionoptions from options.lua
}

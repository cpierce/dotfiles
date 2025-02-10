-- Auto Commands
--

-- Auto Yank to pbcopy
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.system("pbcopy", vim.fn.getreg('"'))
    end
  end,
})

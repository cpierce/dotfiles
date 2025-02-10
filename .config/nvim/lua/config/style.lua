-- Fallback Colorscheme Logic
local ok, _ = pcall(vim.cmd, "colorscheme catppuccin")
if not ok then
  vim.cmd("colorscheme habamax") -- Use built-in colorscheme as fallback
end

-- UI Tweaks (Optional)
vim.opt.termguicolors = true -- Enable true colors
vim.opt.background = "dark" -- Set background to dark

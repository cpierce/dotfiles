-- Fallback Colorscheme Logic
--

local ok, _ = pcall(function()
  vim.cmd("colorscheme catppuccin")
end)

if not ok then
  vim.notify("Failed to load colorscheme catppuccin, falling back to habamax", vim.log.levels.WARN)
  vim.cmd("colorscheme habamax") -- Use built-in colorscheme as fallback
end

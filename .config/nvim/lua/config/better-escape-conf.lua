local function escape_and_clear_empty()
  vim.api.nvim_input('<Esc>')
  local current_line = vim.api.nvim_get_current_line()
  if current_line:match('^%s+$') then
    vim.schedule(function()
      vim.api.nvim_set_current_line('')
    end)
  end
end

return {
  timeout = vim.o.timeoutlen,
  default_mappings = false,
  mappings = {
    i = { j = { j = escape_and_clear_empty } },
    c = { j = { j = '<C-c>' } },
    t = { j = { j = '<C-\\><C-n>' } },
    v = { j = { k = '<Esc>' } },
    s = { j = { k = '<Esc>' } },
  },
}

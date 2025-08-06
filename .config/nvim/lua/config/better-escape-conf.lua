return {
  default_mappings = false,
  mappings = {
    i = { j = { j = '<Esc>' } },
    c = { j = { j = '<C-c>' } },
    t = { j = { j = '<C-\\><C-n>' } },
    v = { j = { k = '<Esc>' } },
    s = { j = { k = '<Esc>' } },
  },
  timeout = vim.o.timeoutlen,
  clear_empty_lines = true,
  keys = '<Esc>',
}

return {
  dir = vim.fn.stdpath("data") .. "/sessions/", -- Store session files
  options = { "buffers", "curdir", "tabpages", "winsize" }, -- What to save
}

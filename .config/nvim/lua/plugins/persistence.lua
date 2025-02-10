return {
  {
    "folke/persistence.nvim",
    event = "VeryLazy", -- Ensure persistence is loaded
    config = function()
      require("persistence").setup({
        dir = vim.fn.stdpath("data") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize" },
      })
    end,
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- Load immediately
    opts = require("config.lualine"), -- Loads external configuration
  },
}

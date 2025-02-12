return {
  {
    "folke/which-key.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = require("config.which-key"),
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },
}

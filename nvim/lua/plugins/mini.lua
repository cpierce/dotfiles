return {
  {
    "echasnovski/mini.ai",
    version = false,
    opts = function()
      return require("config.mini.ai")
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },
  {
    "echasnovski/mini.comment",
    opts = require("config.mini.comment"),
  },
  {
    "echasnovski/mini.icons",
    version = false,
    opts = require("config.mini.icons"),
  },
  {
    "echasnovski/mini.pairs",
    version = false,
    opts = require("config.mini.pairs"),
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = require("config.mini.indentscope"),
  },
}

return {
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local illuminate_opts = require("config.illuminate")
      require("illuminate").configure(illuminate_opts)
    end,
  },
}

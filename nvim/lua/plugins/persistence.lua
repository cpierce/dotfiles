return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = require("config.persistence"),
  },
}

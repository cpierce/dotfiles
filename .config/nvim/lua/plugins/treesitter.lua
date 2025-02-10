return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opt = {},
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "typescript", "javascript", "php", "rust", "html", "css" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}

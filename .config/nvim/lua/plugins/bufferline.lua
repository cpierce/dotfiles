return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local opts = {
        options = {
          mode = "buffers", -- Use "tabs" mode instead of "buffers"
          separator_style = "slant", -- Customize tab separators
          always_show_bufferline = true, -- Always show tabs
          diagnostics = "nvim_lsp",
          offsets = { { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true } },
          show_buffer_close_icons = true,
          show_close_icon = true,
          indicator = {
            style = "underline", -- Highlight active tab with underline
          },
        },
      }

      -- Integrate Catppuccin highlights if the colorscheme is Catppuccin
      if (vim.g.colors_name or ""):find("catppuccin") then
        opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
      end

      -- Apply the configuration
      require("bufferline").setup(opts)
    end,
  },
}

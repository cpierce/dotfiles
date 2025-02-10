return {
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim", -- Required for UI elements
      "rcarriga/nvim-notify", -- Optional, for notifications
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true, -- Enhanced command-line UI
        },
        messages = {
          enabled = true, -- Show LSP and system messages in a popup
          view = "mini", -- Use the popup view for messages
          timeout = 5000, -- 5 seconds
        },
        popupmenu = {
          enabled = true, -- Custom popup menu for completions
        },
        lsp = {
          progress = {
            enabled = true, -- Show LSP progress messages
          },
          hover = {
            enabled = true, -- Enable hover popups
          },
          signature = {
            enabled = true, -- Enable signature help popups
          },
        },
        presets = {
          bottom_search = true, -- Move the search bar to the bottom
          command_palette = true, -- Command line UI like a palette
          long_message_to_split = true, -- Send long messages to a split
        },
      })
    end,
  },
}

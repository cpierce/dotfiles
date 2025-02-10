return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional for icons
    cmd = { "TroubleToggle", "Trouble" }, -- Lazy-load commands
    config = function()
      require("trouble").setup({
        position = "bottom", -- Position of the list: bottom, top, left, right
        height = 10, -- Height of the list when position is bottom or top
        width = 50, -- Width of the list when position is left or right
        icons = true, -- Enable icons
        mode = "workspace_diagnostics", -- Default mode: "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = "", -- Icon for open folds
        fold_closed = "", -- Icon for closed folds
        group = true, -- Group results by file
        padding = true, -- Add an extra new line on top of the list
        action_keys = { -- Key mappings for actions in the trouble list
          close = "q", -- Close the list
          cancel = "<esc>", -- Cancel the preview
          refresh = "r", -- Refresh diagnostics
          jump = { "<cr>", "<tab>" }, -- Jump to the diagnostic or reference
          open_split = { "<c-x>" }, -- Open in a split
          open_vsplit = { "<c-v>" }, -- Open in a vertical split
          open_tab = { "<c-t>" }, -- Open in a new tab
          toggle_fold = { "zA", "za" }, -- Toggle folds
          previous = "k", -- Previous item
          next = "j", -- Next item
        },
        indent_lines = true, -- Show indent guide lines
        auto_open = false, -- Automatically open Trouble when there are diagnostics
        auto_close = false, -- Automatically close Trouble when there are no diagnostics
        auto_preview = true, -- Automatically preview the location of the diagnostic
        auto_fold = false, -- Automatically fold a file's diagnostics
        signs = {
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "",
        },
        use_diagnostic_signs = true, -- Use signs defined in LSP client
      })
    end,
  },
}

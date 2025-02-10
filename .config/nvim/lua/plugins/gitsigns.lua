return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Load only when opening a file
    dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "" },
          change = { text = "" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "" },
        },
        signcolumn = true, -- Show git signs in the sign column
        numhl = true, -- Enable line number highlighting
        linehl = true, -- Enable line highlighting
        word_diff = false, -- Disable word diff
        current_line_blame = true, -- Inline blame
        current_line_blame_opts = {
          delay = 500, -- Delay before showing blame
          virt_text_pos = "eol", -- Show blame at the end of the line
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        watch_gitdir = {
          interval = 1000, -- Check for changes every 1 second
          follow_files = true, -- Follow moved or renamed files
        },
        attach_to_untracked = true, -- Attach to files not yet committed
        update_debounce = 200, -- Debounce updates
        status_formatter = nil, -- Use default status formatting
        max_file_length = 40000, -- Skip files longer than 40,000 lines
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Keymaps
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          -- Actions
          map("n", "<leader>hs", gs.stage_hunk)
          map("n", "<leader>hr", gs.reset_hunk)
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>tb", gs.toggle_current_line_blame)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end)
          map("n", "<leader>td", gs.toggle_deleted)

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },
}

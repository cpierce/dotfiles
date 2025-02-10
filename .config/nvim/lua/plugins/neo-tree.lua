return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      "nvim-tree/nvim-web-devicons", -- Optional, for file icons
      "MunifTanjim/nui.nvim", -- Required for UI components
    },
    config = function()
      -- Function to check if the current directory is a Git repository
      local function is_git_repo()
        local git_dir = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
        return vim.v.shell_error == 0
      end

      -- Setup Neo-tree
      require("neo-tree").setup({
        close_if_last_window = true, -- Close Neo-tree if it's the last window
        popup_border_style = "rounded", -- Rounded popup borders
        enable_git_status = true, -- Enable Git integration
        enable_diagnostics = true, -- Show diagnostics in the tree
        default_component_configs = {
          git_status = {
            symbols = {
              added = "✚", -- Icon for added files
              modified = "", -- Icon for modified files
              deleted = "✖", -- Icon for deleted files
              renamed = "", -- Icon for renamed files
              untracked = "★", -- Icon for untracked files
              ignored = "◌", -- Icon for ignored files
              unstaged = "󰄱", -- Unstaged files
              staged = "󰱒", -- Staged files
            },
          },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false, -- Show hidden files
            hide_gitignored = false, -- Show Git-ignored files
          },
          follow_current_file = true, -- Follow the file currently being edited
          use_libuv_file_watcher = true, -- Autorefresh on file changes
          hijack_netrw_behavior = "open_default", -- Replace `netrw`
          window = {
            position = "left", -- Sidebar on the left
            width = 35, -- Sidebar width
            mappings = {
              ["<space>"] = "toggle_node", -- Space to expand/collapse
              ["h"] = "close_node", -- Move up to the parent folder
              ["l"] = "open", -- Open the file or folder
              ["-"] = "navigate_up", -- Move up to the parent folder
              ["<CR>"] = "open", -- Enter to open files
              ["o"] = "open", -- Open files with "o"
              ["Y"] = {
                function(state)
                  local node = state.tree:get_node()
                  local path = node:get_id()
                  vim.fn.setreg("+", path, "c")
                end,
                desc = "Copy Path",
              },
            },
          },
        },
        git_status = {
          window = {
            mappings = {
              ["a"] = "git_add_all", -- Add all changes
              ["c"] = "git_commit", -- Commit staged changes
              ["p"] = "git_push", -- Push committed changes
              ["S"] = "git_stash", -- Stash changes
              ["b"] = "git_checkout_branch", -- Checkout a branch
              ["R"] = "refresh", -- Refresh the Git status view
              ["q"] = "close_window", -- Close Neo-tree Git window
            },
          },
          commands = {
            git_add_all = function()
              vim.fn.system("git add -A")
              print("✔ Staged all changes.")
            end,
            git_commit = function()
              vim.ui.input({ prompt = "Commit message: " }, function(msg)
                if msg then
                  vim.fn.system("git commit -m " .. vim.fn.shellescape(msg))
                  print("✔ Committed with message: " .. msg)
                else
                  print("✘ Commit aborted.")
                end
              end)
            end,
            git_push = function()
              local branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
              vim.fn.system("git push origin " .. branch)
              print("✔ Pushed to branch: " .. branch)
            end,
            git_stash = function()
              vim.ui.input({ prompt = "Stash message (optional): " }, function(msg)
                if msg then
                  vim.fn.system("git stash push -m " .. vim.fn.shellescape(msg))
                  print("✔ Changes stashed with message: " .. msg)
                else
                  vim.fn.system("git stash")
                  print("✔ Changes stashed.")
                end
              end)
            end,
            git_checkout_branch = function()
              vim.fn.system("git fetch --all")
              vim.fn.jobstart("git branch -a", {
                on_stdout = function(_, data)
                  if not data then
                    return
                  end
                  -- Prompt user to choose a branch
                  vim.ui.select(data, { prompt = "Choose a branch:" }, function(choice)
                    if choice then
                      vim.fn.system("git checkout " .. choice)
                      print("✔ Switched to branch: " .. choice)
                    else
                      print("✘ Branch switch aborted.")
                    end
                  end)
                end,
              })
            end,
          },
        },
      })

      -- Auto-open Neo-tree on VimEnter
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Load session if no files are passed as arguments
          if vim.fn.argc() == 0 then
            require("persistence").load()
            require("gitsigns").refresh()
          end

          -- Open filesystem view on the left
          require("neo-tree.command").execute({
            action = "show",
            source = "filesystem",
            position = "left",
            dir = vim.fn.getcwd(),
          })

          -- Open Git status view on the right if inside a Git repo
          if is_git_repo() then
            require("neo-tree.command").execute({
              action = "show",
              source = "git_status",
              position = "right",
            })
          end

          -- Cleanup invalid buffers
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(bufnr, "buflisted") and not vim.api.nvim_buf_is_loaded(bufnr) then
              vim.api.nvim_buf_delete(bufnr, { force = true })
            end
            if vim.api.nvim_buf_is_loaded(bufnr) then
              vim.api.nvim_buf_call(bufnr, function()
                vim.cmd("doautocmd BufRead")
              end)
            end
          end
        end,
      })

      -- Auto-close Neo-tree before quitting
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          vim.cmd("Neotree close")
        end,
      })
    end,
  },
}

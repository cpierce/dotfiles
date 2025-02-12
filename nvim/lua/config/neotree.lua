return {
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    git_status = {
      symbols = {
        added = "✚",
        modified = "",
        deleted = "✖",
        renamed = "",
        untracked = "★",
        ignored = "◌",
        unstaged = "󰄱",
        staged = "󰱒",
      },
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    follow_current_file = true,
    use_libuv_file_watcher = true,
    hijack_netrw_behavior = "open_default",
    window = {
      position = "left",
      width = 35,
    },
    mappings = {
      ["<space>"] = "toggle_node",
      ["h"] = "close_node",
      ["l"] = "open",
      ["-"] = "navigate_up",
      ["<CR>"] = "open",
      ["o"] = "open",
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
  git_status = {
    window = {
      position = "bottom",
      height = 4,
      border = "double",
    },
    mappings = {
      ["a"] = "git_add_all",
      ["c"] = "git_commit",
      ["p"] = "git_push",
      ["S"] = "git_stash",
      ["R"] = "refresh",
      ["q"] = "close_window",
    },
    commands = {
      git_add_all = require("utils.git").git_add_all,
      git_commit = require("utils.git").git_commit,
      git_push = require("utils.git").git_push,
      git_stash = require("utils.git").git_stash,
    },
  },
}

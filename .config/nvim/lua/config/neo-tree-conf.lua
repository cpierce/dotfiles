local icons = require('utils.icons')

return {
  close_if_last_window = true,
  enable_diagnostics = true,
  enable_git_status = true,
  open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
  popup_border_style = 'rounded',
  default_component_configs = {
    git_status = {
      symbols = {
        added = icons.git.LineAdded,
        modified = icons.git.LineModified,
        deleted = icons.git.FileRemoved,
        renamed = icons.git.FileRenamed,
        untracked = icons.git.FileUntracked,
        ignored = icons.git.FileIgnored,
        unstaged = icons.git.FileUnstaged,
        staged = icons.git.FileStaged,
      },
    },
  },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  source_selector = {
    winbar = true,
  },
  window = {
    position = 'left',
    width = 40,
    mappings = {
      ['.'] = 'set_root',
    },
  },
  git_status = {
    window = {
      mappings = {
        ['A'] = 'git_add_all',
      },
    },
  },
}

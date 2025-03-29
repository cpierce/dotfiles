return {
  animate = {},
  bigfile = {},
  bufdelete = {},
  dashboard = {
    preset = {
      header = [[
 ██████╗██████╗ ██╗███████╗██████╗  ██████╗███████╗
██╔════╝██╔══██╗██║██╔════╝██╔══██╗██╔════╝██╔════╝
██║     ██████╔╝██║█████╗  ██████╔╝██║     █████╗  
██║     ██╔═══╝ ██║██╔══╝  ██╔══██╗██║     ██╔══╝  
╚██████╗██║     ██║███████╗██║  ██║╚██████╗███████╗
 ╚═════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝
]],
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      },
    },
    sections = {
      { section = 'header' },
      { pane = 2, section = 'keys', padding = 1 },
      { pane = 2, title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      {
        icon = ' ',
        title = 'Git Status',
        section = 'terminal',
        enabled = function()
          return Snacks.git.get_root() ~= nil
        end,
        cmd = 'git status --short --branch --renames',
        height = 7,
        padding = 1,
        ttl = 5 * 60,
        indent = 2,
      },
      { section = 'startup' },
    },
  },
  git = {},
  gitbrowse = {},
  indent = {
    char = '▏',
  },
  input = {},
  lazygit = {},
  notifier = {},
  picker = {
    sources = {
      files = {
        hidden = true,
      },
    },
  },
  scroll = {},
  statuscolumn = {
    folds = {
      git_hl = true,
    },
  },
  terminal = {},
  words = {},
}

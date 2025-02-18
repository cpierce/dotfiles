return {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '-' },
    topdelete = { text = '-' },
    changedelete = { text = '~' },
    untracked = { text = '▎' },
  },
  signs_staged = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '-' },
    topdelete = { text = '-' },
    changedelete = { text = '~' },
  },
  signcolumn = true,
  numhl = true,
  linehl = true,
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
    virt_text_pos = 'eol',
  },
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  update_debounce = 200,
  status_formatter = nil,
  max_file_length = 40000,

  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
    end

    map('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
    map('n', '<leader>ghb', function()
      gs.blame_line({ full = true })
    end, 'Blame Line')
    map('n', '<leader>ghB', function()
      gs.blame()
    end, 'Blame Buffer')
    map('n', '<leader>ghd', gs.diffthis, 'Diff This')
  end,
}

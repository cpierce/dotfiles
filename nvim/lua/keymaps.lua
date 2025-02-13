-- Keymaps
--
local map = vim.keymap.set

-- jj to escape insert mode
map('i', 'jj', '<Esc>')

-- Easy window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- File Saving
map('n', '<C-s>', ':w<CR>', { silent = true })

-- Disable Arrow Key
map('', '<Left>', '<Nop>', { noremap = true, silent = true })
map('', '<Right>', '<Nop>', { noremap = true, silent = true })
map('', '<Up>', '<Nop>', { noremap = true, silent = true })
map('', '<Down>', '<Nop>', { noremap = true, silent = true })

-- Mason
map('n', '<leader>cm', '<cmd>Mason<cr>', { noremap = true, silent = true, desc = 'Mason' })

-- Indent and stay in visual mode
map('v', '<', '<gv', { noremap = true, silent = true })
map('v', '>', '>gv', { noremap = true, silent = true })

-- Buffer Switching using <leader><leader>
map('n', '<leader><leader', '<C-^>', { noremap = true, silent = true })

-- File keyboard shortcuts
map('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true, desc = 'Find Files (Telescope)' })
map('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true, desc = 'Live Grep (Telescope)' })
map('n', '<leader>fn', ':enew<CR>', { silent = true, desc = 'New File' })

-- Remap 0 to the first non-blank character
map('n', '0', '^', { noremap = true, silent = true })

-- Run Lazy sync with <leader>i
map('n', '<leader>ls', ':Lazy sync<CR>', { noremap = true, silent = true, desc = 'Sync Lazy' })
map('n', '<leader>lc', ':Lazy clean<CR>', { noremap = true, silent = true, desc = 'Clean Lazy' })
map('n', '<leader>lu', ':Lazy update<CR>', { noremap = true, silent = true, desc = 'Update Lazy' })

-- Comment with ///
map('n', '///', function()
  require('mini.comment').toggle_lines(vim.fn.line('.'), vim.fn.line('.'))
end, { noremap = true, silent = true })

-- Enter exits search mode
map('n', '<CR>', function()
  if vim.v.hlsearch == 1 then
    vim.cmd('nohlsearch')
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true })

-- Spectre Search and Replace
map('n', '<C-f>', '<cmd>lua require("spectre").toggle()<CR>', { noremap = true, silent = true })
map('n', '<leader>ss', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { noremap = true, silent = true })

-- NeoTree and File Shortcuts
map('n', '<leader>nn', ':NeoTreeShowToggle<CR>', { silent = true })
map('n', '<leader>ns', ':NeoTreeShowToggle git_status<CR>', { silent = true })

-- Tabs
map('n', '<tab><tab>', ':BufferLineCycleNext<CR>', { silent = true })
map('n', '<S-tab><S-tab>', ':BufferLineCyclePrev<CR>', { silent = true })

-- Yank All to Clipboard
map('n', '<leader>ya', function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Save cursor position
  vim.cmd('normal! ggVGy') -- Select all, yank
  vim.api.nvim_win_set_cursor(0, { line, col }) -- Restore cursor position
end, {
  noremap = true,
  silent = true,
  desc = 'Yank All',
})

-- Trouble.nvim Keybindings
local trouble = require('trouble')

map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
map('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (Trouble)' })
map('n', '<leader>cS', '<cmd>Trouble lsp toggle<cr>', { desc = 'LSP references/definitions/... (Trouble)' })
map('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })

map('n', '[q', function()
  if trouble.is_open() then
    trouble.prev({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = 'Previous Trouble/Quickfix Item' })

map('n', ']q', function()
  if trouble.is_open() then
    trouble.next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = 'Next Trouble/Quickfix Item' })

-- Reload previous session
map('n', '<leader>ql', function()
  require('persistence').load({ last = true })
  require('neo-tree.command').execute({
    action = 'show',
    source = 'filesystem',
    position = 'left',
    dir = vim.fn.getcwd(),
  })
end, { desc = 'Restore Last Session' })

-- Illuminate command
map('n', '<leader>in', require('illuminate').goto_next_reference, { desc = 'Next reference' })
map('n', '<leader>ip', require('illuminate').goto_prev_reference, { desc = 'Previous reference' })

-- Disable session
map('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = 'Disable Session Saving' })

map('n', '<leader>fo', '<Cmd>Oil<CR>', { silent = true })

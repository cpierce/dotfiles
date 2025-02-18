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
map('n', '<C-s>', ':w<cr>', { silent = true })

-- Disable Arrow Key
map('', '<Down>', '<Nop>', { noremap = true, silent = true })
map('', '<Left>', '<Nop>', { noremap = true, silent = true })
map('', '<Right>', '<Nop>', { noremap = true, silent = true })
map('', '<Up>', '<Nop>', { noremap = true, silent = true })

-- Indent and stay in visual mode
map('v', '<', '<gv', { noremap = true, silent = true })
map('v', '>', '>gv', { noremap = true, silent = true })

-- Buffer Switching using <leader><leader>
map('n', '<leader><leader>', '<cmd>BufferLineCycleNext<cr>', { noremap = true, silent = true, desc = 'switch buffer' })

-- File keyboard shortcuts
map('n', '<leader>fn', '<cmd>enew<cr>', { silent = true, desc = 'new file' })

-- Remap 0 to the first non-blank character
map('n', '0', '^', { noremap = true, silent = true })

-- Run Lazy sync with <leader>i
map('n', '<leader>ls', '<cmd>Lazy sync<cr>', { noremap = true, silent = true, desc = 'Sync (lazy)' })
map('n', '<leader>lc', '<cmd>Lazy clean<cr>', { noremap = true, silent = true, desc = 'Clean (lazy)' })
map('n', '<leader>lu', '<cmd>Lazy update<cr>', { noremap = true, silent = true, desc = 'Update (lazy)' })

-- Noice Commands
map('n', '<leader>ml', function()
  require('noice').cmd('last')
end, { silent = true, desc = 'Show Last Message (noice)' })
map('n', '<leader>mh', function()
  require('noice').cmd('history')
end, { silent = true, desc = 'Show History (noice)' })
map('n', '<leader>ma', function()
  require('noice').cmd('all')
end, { silent = true, desc = 'Show All (noice)' })

-- Enter exits search mode
map('n', '<cr>', function()
  if vim.v.hlsearch == 1 then
    vim.cmd('nohlsearch')
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true })

-- Spectre Search and Replace
map('n', '<C-f>', function()
  require('spectre').toggle()
end, { noremap = true, silent = true, desc = 'Search and Replace (spectre)' })

map('n', '<leader>fr', function()
  require('spectre').toggle()
end, { noremap = true, silent = true, desc = 'Search and Replace (spectre)' })
map(
  'n',
  '<leader>fw',
  '<cmd>lua require("spectre").open_file_search({select_word=true})<cr>',
  { noremap = true, silent = true, desc = 'Search Selected Word (spectre)' }
)

-- Snacks

-- Tabs
map('n', '<tab><tab>', '<cmd>BufferLineCycleNext<cr>', { silent = true, desc = 'Next Buffer' })
map('n', '<S-tab><S-tab>', '<cmd>BufferLineCyclePrev<cr>', { silent = true, desc = 'Prev Buffer' })
map('', '<leader>bc', '<cmd>BufferLineCloseOthers<cr>', { silent = true, desc = 'Delete All But Current' })
map('', '<leader>bn', '<cmd>BufferLineCycleNext<cr>', { silent = true, desc = 'Next Buffer' })
map('', '<leader>bp', '<cmd>BufferLineCyclePrev<cr>', { silent = true, desc = 'Prev Buffer' })

-- Yank All to Clipboard
map('n', '<leader>ya', function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Save cursor position
  vim.cmd('normal! ggVGy') -- Select all, yank
  vim.api.nvim_win_set_cursor(0, { line, col }) -- Restore cursor position
end, {
  noremap = true,
  silent = true,
  desc = 'Yank File Contents',
})

-- Conform Formatting
map('n', '<leader>cf', function()
  require('conform').format({ async = true, lsp_fallback = true })
end, { noremap = true, silent = true, desc = 'Format File' })

-- Code Sort/Order
map('n', '<leader>cI', '<cmd>sort I<cr>', { silent = true, desc = 'Order (no-case reverse)' })
map('n', '<leader>cO', '<cmd>sort!<cr>', { silent = true, desc = 'Order (reverse)' })
map('n', '<leader>ci', '<cmd>sort i<cr>', { silent = true, desc = 'Order (no-case)' })
map('n', '<leader>co', '<cmd>sort<cr>', { silent = true, desc = 'Order' })
map('v', '<leader>cI', ":'<,'>sort I<cr>", { silent = true, desc = 'Order (no-case reverse)' })
map('v', '<leader>cO', ":'<,'>sort!<cr>", { silent = true, desc = 'Order (reverse)' })
map('v', '<leader>ci', ":'<,'>sort i<cr>", { silent = true, desc = 'Order (no-case)' })
map('v', '<leader>co', ":'<,'>sort<cr>", { silent = true, desc = 'Order' })

-- Trouble.nvim Keybindings
local trouble = require('trouble')

map('n', '<leader>cS', '<cmd>Trouble lsp toggle<cr>', { desc = 'LSP References/Definitions/... (trouble)' })
map('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (trouble)' })
map('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (trouble)' })
map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quick List (trouble)' })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (trouble)' })
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (trouble)' })

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
end, { desc = 'Restore Last Session (persistence)' })

-- Illuminate command
map('n', '<leader>in', require('illuminate').goto_next_reference, { desc = 'Next Reference (illuminate)' })
map('n', '<leader>ip', require('illuminate').goto_prev_reference, { desc = 'Prev Reference (illuminate)' })

-- Disable session
map('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = 'Disable Session Saving (persistence)' })

map('n', '<leader>fo', '<cmd>Oil<cr>', { silent = true, desc = 'Open (oil)' })

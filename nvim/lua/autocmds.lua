-- Auto Commands
--
local api = vim.api

-- Auto compile scss on save
api.nvim_create_autocmd('FileType', {
  pattern = 'scss',

  callback = function()
    api.nvim_set_keymap('n', '<leader>cm', ':w <BAR> !sass %:%:r.css<CR><space>', { noremap = true, silent = true, desc = 'Compile Sass' })
  end,
})

api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    api.nvim_set_hl(0, 'Folded', { bg = '#333333' })
  end,
})

-- Auto reload file saved from the outside
api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = "if mode() != 'c' | checktime | endif",
})

-- Disable Mini IndentScope for specific filetypes
api.nvim_create_autocmd('FileType', {
  pattern = {
    'alpha',
    'dashboard',
    'fzf',
    'gitsigns-blame',
    'help',
    'mason',
    'notify',
    'spectre_panel',
    'toggleterm',
    'Trouble',
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Highlight on yank
api.nvim_set_hl(0, 'YankHighlight', { bg = '#7ba2e2', fg = '#000000', bold = true })
api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'YankHighlight', timeout = 200 })
  end,
})

-- Auto-open NeoTree on startup
api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    require('neo-tree.command').execute({ action = 'show' })
    if vim.fn.argc() > 0 then
      vim.defer_fn(function()
        vim.cmd('wincmd p')
      end, 100)
    end
  end,
})
-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'checkhealth',
    'gitsigns-blame',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'spectre_panel',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
  callback = function()
    vim.schedule(function()
      pcall(nvim_bufferline)
    end)
  end,
})

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function()
    -- Get the number of windows still open
    local win_count = #vim.api.nvim_list_wins()

    -- Check if Snacks Explorer is still open
    --local snacks_open = require('snacks').explorer.is_open()

    -- If Snacks is the only window left, quit Neovim
    --if win_count == 1 and snacks_open then
    --vim.cmd('qa!')
    --end
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto-close NeoTree before quitting
api.nvim_create_autocmd('QuitPre', {
  callback = function()
    require('persistence').save()
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Auto Commands
--
local api = vim.api

-- Auto compile scss on save
api.nvim_create_autocmd('FileType', {
  pattern = 'scss',

  callback = function()
    api.nvim_set_keymap('n', ',m', ':w <BAR> !sass %:%:r.css<CR><space>', { noremap = true, silent = true })
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
    'Trouble',
    'alpha',
    'dashboard',
    'fzf',
    'help',
    'lazy',
    'mason',
    'neo-tree',
    'notify',
    'toggleterm',
    'trouble',
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- Auto-open NeoTree on startup
api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Open filesystem view on the left
    require('neo-tree.command').execute({
      action = 'show',
      source = 'filesystem',
      position = 'left',
      dir = vim.fn.getcwd(),
    })

    -- Cleanup invalid buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.fn.buflisted(bufnr) and vim.fn.bufloaded(bufnr) == 0 then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd('doautocmd BufRead')
        end)
      end
    end
  end,
})

-- Auto-close NeoTree before quitting
api.nvim_create_autocmd('QuitPre', {
  callback = function()
    vim.cmd('Neotree close')
    require('persistence').save()
  end,
})

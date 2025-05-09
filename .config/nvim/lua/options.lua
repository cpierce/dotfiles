-- Options
--
local opt = vim.opt

-- Mouse mode
opt.mouse = 'a'

-- Error Sounds, ugh!
opt.errorbells = false -- No annoying beep sounds
opt.visualbell = false -- No screen flash on errors
opt.timeoutlen = 500 -- Adjusts key mapping timeout (if needed)

-- Numbers
opt.number = true
opt.relativenumber = true

-- Sessions
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

-- Tab Stuff
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true

-- File and Clipboard Stuff
opt.backup = false -- Disable backup files
opt.writebackup = false -- Disable write backups for files
opt.swapfile = false -- Disable swap files
opt.backspace = { 'indent', 'eol', 'start' } -- Allow backspace over everything
opt.clipboard = 'unnamedplus'

-- UI Tweaks
opt.termguicolors = true -- Enable true colors
opt.background = 'dark' -- Set background to dark
opt.wrap = false -- Disable line wrapping
opt.linebreak = true -- Prevent midwork break
opt.sidescrolloff = 8 -- Pad scrolling sideways
opt.scrolloff = 10 -- Keeps 10 lines above/below the cursor
opt.smoothscroll = true -- Enable smooth scroll
opt.textwidth = 158 -- Set textwidth gutter at 78 characters
opt.colorcolumn = '160' -- Show visible line for wrap
opt.formatoptions:append('l')
opt.shortmess:append('I')

-- Highlight the line number only
opt.cursorline = true -- Highlight the current line
opt.cursorlineopt = 'number' -- Only highlight the line number

-- Spelling
opt.spelllang = { 'en' }

-- Ignore random nonsense files
opt.wildmode = 'longest:full,full'
opt.wildignore = '*.swp,*.bak'
opt.grepprg = "rg --vimgrep --hidden --glob '!.git/'"
opt.grepformat = '%f:%l:%c:%m'

-- Folding options
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
opt.foldmethod = 'expr'
opt.foldexpr = "v:lua.require'utils.folding'.foldexpr()"
opt.signcolumn = 'yes'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ''

-- Ignore case unless case is used
opt.ignorecase = true
opt.smartcase = true

-- Enable persistent undo
opt.undofile = true
opt.undolevels = 10000

-- Ignore copilot lsp
vim.g.root_lsp_ignore = { 'copilot' }
vim.g.markdown_recommended_style = 0
vim.g.ai_cmp = true

vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
})

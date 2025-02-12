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

-- Tab Stuff
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true

-- File and Clipboard Stuff
opt.backup = false -- Disable backup files
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

-- Highlight the line number only
opt.cursorline = true -- Highlight the current line
opt.cursorlineopt = 'number' -- Only highlight the line number

-- Ignore random nonsense files
opt.wildignore = '*.swp,*.bak'
opt.grepprg = "rg --vimgrep --hidden --glob '!.git/'"
opt.grepformat = '%f:%l:%c:%m'

-- Ignore case unless case is used
opt.ignorecase = true
opt.smartcase = true

-- Enable persistent undo
opt.undofile = true
opt.undodir = vim.fn.expand('~/.vim/undodir')

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- jj to escape insert mode
map("i", "jj", "<Esc>")

-- Easy window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Save with Ctrl + S
map("n", "<C-s>", ":w<CR>", { silent = true })

-- Disable Arrow Key
map("n", "<Left>", "<Nop>")
map("n", "<Right>", "<Nop>")
map("n", "<Up>", "<Nop>")
map("n", "<Down>", "<Nop>")

-- Indent and stay in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Buffer Switching using <leader><leader>
map("n", "<leader><leader", "<c-^>")

-- Tabs
map("n", "<tab><tab>", ":tabn<CR>", { silent = true })
map("n", "<leader>tc", ":tabclose<CR>", { silent = true })
map("n", "<leader>to", ":tabonly<CR>", { silent = true })

-- Search tweaks
map("n", "<CR>", ":nohlsearch<CR>", { silent = true })

-- Oil Setup
map("n", "-", "<CMD>Oil<CR>")

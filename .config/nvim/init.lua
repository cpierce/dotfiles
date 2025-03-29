-- Initial Install
vim.g.mapleader = ','
vim.g.maplocalleader = ','

require('lazy-bootstrap')
require('autocmds')
require('keymaps')
require('options')
require('lsp')
require('style')

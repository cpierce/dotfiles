-- Initial Install
vim.g.mapleader = ','
vim.g.maplocalleader = ','

require('config.lazy')
require('autocmds')
require('keymaps')
require('options')
require('style')

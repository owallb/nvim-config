vim.g.mapleader = " "
vim.g.vimsyn_embed = "lpP"
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 1
vim.g.netrw_list_hide = '\\.venv/,\\.git/'
vim.g.netrw_maxfilenamelen = 47
vim.g.netrw_mousemaps = 0
vim.g.netrw_sizestyle = 'H'
vim.g.netrw_sort_by = 'name'
vim.g.netrw_sort_options = 'i'
vim.g.netrw_sort_sequence = '[\\/]\\s*,*'
vim.g.netrw_special_syntax = 1
vim.g.netrw_timefmt = '%d-%m-%Y %H:%M'
vim.g.c_syntax_for_h = 1

local termfeatures = vim.g.termfeatures or {}
termfeatures.osc52 = false
vim.g.termfeatures = termfeatures

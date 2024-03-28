vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.mousemodel = "popup"
vim.opt.fillchars = {
    diff = " ",
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
}
vim.opt.splitbelow = true
vim.opt.splitright = true
-- set tabline=%!MyTabLine()
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = false
-- Folds are configured in nvim-treesitter, so this is only for fallback
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "indent"
vim.opt.foldignore = ""
vim.opt.guifont = "JetBrains Mono:11"
vim.opt.completeopt:append({
    "menu",
    "menuone",
    "preview",
    "noinsert",
    "noselect",
})
-- set nowrap
vim.opt.matchpairs:append({ "<:>", "':'", "\":\"", })
vim.opt.fileencoding = "utf-8"
-- Only relevant with wrap enabled (default)
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪"
-- Minimum amount of lines to show offset +/- to cursorline
vim.opt.scrolloff = 3
vim.opt.visualbell = true
vim.opt.errorbells = false
-- Persistent undo even after you close a file and re-open it
vim.opt.undofile = true
-- Insert mode key word completion setting, see :h 'compelete'
-- and https://medium.com/usevim/set-complete-e76b9f196f0f#:~:text=When%20in%20Insert%20mode%2C%20you,%2D%2D%20CTRL%2DN%20goes%20backwards.
-- kspell is only relevant if ':set spell' is toggled on, e.g. when editing
-- documents
vim.opt.complete = ".,kspell"
vim.opt.spelllang = "en"
-- Align indent to next multiple value of shiftwidth.
-- E.g., only insert as many spaces necessary for reaching the next shiftwidth
vim.opt.shiftround = true
-- Allow virtualedit (editing on empty spaces) in visual block mode (Ctrl+V)
vim.opt.virtualedit = "block"
-- True color support. Avoid if terminal does not support it.
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:2"
-- Diff options
vim.opt.diffopt = {}
-- Use vertical split by default
vim.opt.diffopt:append("vertical")
-- Insert filler lines
vim.opt.diffopt:append("filler")
-- Execute :diffoff when only one diff window remain
vim.opt.diffopt:append("closeoff")
-- Use internal diff library
vim.opt.diffopt:append("internal")
-- These make diffs easier to read, please see the following:
-- https://vimways.org/2018/the-power-of-diff/
vim.opt.diffopt:append({ "indent-heuristic", "algorithm:histogram", })
vim.cmd.filetype("plugin on")
vim.opt.hlsearch = true
vim.opt.laststatus = 3
vim.opt.textwidth = 0
vim.opt.colorcolumn = "101"
vim.opt.shortmess:append("a")
vim.opt.autoread = true
-- vim.opt.cmdheight = 0 -- To hide cmdline when not used. Disabled due to
-- causing "Press ENTER to continue" messages for small messages.

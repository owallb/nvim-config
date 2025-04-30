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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = false
-- Folds are configured in nvim-treesitter, so this is only for fallback
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "indent"
vim.opt.foldignore = ""
vim.opt.completeopt:append({
    "menu",
    "menuone",
    "preview",
    "noinsert",
    "noselect",
})
-- set nowrap
vim.opt.matchpairs:append({ "<:>", })
-- Only relevant with wrap enabled (default)
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "  "
-- Minimum amount of lines to show offset +/- to cursorline
vim.opt.scrolloff = 3
vim.opt.visualbell = true
vim.opt.errorbells = false
-- Persistent undo even after you close a file and re-open it
vim.opt.undofile = true
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
vim.opt.diffopt:append("linematch:40")
vim.opt.hlsearch = true
vim.opt.laststatus = 2
vim.opt.textwidth = 0
vim.opt.colorcolumn = "81"
vim.opt.shortmess:append("a")
vim.opt.autoread = true
-- vim.opt.cmdheight = 0 -- To hide cmdline when not used. Disabled due to
-- causing "Press ENTER to continue" messages for small messages.
vim.opt.jumpoptions = {'stack', 'view', 'clean'}
vim.opt.updatetime = 100

function _G._status_line_git()
    local status = vim.b.gitsigns_status_dict

    if not status then
        return ''
    end

    local added = status.added or 0
    local changed = status.changed or 0
    local removed = status.removed or 0

    local parts = {}

    if added > 0 then
        table.insert(parts, string.format("%%#GitSignsAdd#+%d%%*", status.added))
    end

    if changed > 0 then
        table.insert(parts, string.format('%%#GitSignsChange#~%d%%*', status.changed))
    end

    if removed > 0 then
        table.insert(parts, string.format('%%#GitSignsDelete#-%d%%*', status.removed))
    end

    return table.concat(parts, " ")
end

function _G._status_line_diagnostics()
    local diag = vim.diagnostic.count(0)
    local err = diag[vim.diagnostic.severity.ERROR] or 0
    local warn = diag[vim.diagnostic.severity.WARN] or 0
    local hint = diag[vim.diagnostic.severity.HINT] or 0
    local info = diag[vim.diagnostic.severity.INFO] or 0
    local parts = {}

    if err > 0 then
        table.insert(parts, string.format("%%#DiagnosticError#E%d%%*", err))
    end

    if warn > 0 then
        table.insert(parts, string.format('%%#DiagnosticWarn#W%d%%*', warn))
    end

    if hint > 0 then
        table.insert(parts, string.format('%%#DiagnosticHint#H%d%%*', hint))
    end

    if info > 0 then
        table.insert(parts, string.format('%%#DiagnosticInfo#I%d%%*', info))
    end

    return table.concat(parts, " ")
end

vim.opt.statusline = " %{expand('%:.')}%4( %m%) %{%v:lua._status_line_git()%} %="
                     .. " %{%v:lua._status_line_diagnostics()%} "
                     .. " %{&filetype}  %-6.6{&fileencoding}"
                     .. " %-4.4{&fileformat} %4.4(%p%%%)%6.6l:%-3.3v"

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

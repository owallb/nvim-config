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
vim.opt.matchpairs:append({ "<:>" })
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
vim.opt.diffopt = {
    "vertical",
    "filler",
    "closeoff",
    "internal",
    "indent-heuristic",
    "algorithm:histogram",
    "linematch:60",
}
vim.opt.hlsearch = true
vim.opt.laststatus = 2
vim.opt.textwidth = 0
vim.opt.colorcolumn = "81"
vim.opt.shortmess:append("a")
vim.opt.autoread = true
-- vim.opt.cmdheight = 0 -- To hide cmdline when not used. Disabled due to
-- causing "Press ENTER to continue" messages for small messages.
vim.opt.jumpoptions = { "stack", "view", "clean" }
vim.opt.updatetime = 100
vim.opt.guicursor:append("a:Cursor")
vim.opt.inccommand = "split"
vim.opt.winborder = "rounded"

function _G._status_line_git()
    local status = vim.b.gitsigns_status_dict

    if not status then
        return ""
    end

    local added = status.added or 0
    local changed = status.changed or 0
    local removed = status.removed or 0

    local parts = {}

    if added > 0 then
        table.insert(
            parts,
            string.format("%%#GitSignsAdd#+%d%%*", status.added)
        )
    end

    if changed > 0 then
        table.insert(
            parts,
            string.format("%%#GitSignsChange#~%d%%*", status.changed)
        )
    end

    if removed > 0 then
        table.insert(
            parts,
            string.format("%%#GitSignsDelete#-%d%%*", status.removed)
        )
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
        table.insert(parts, string.format("%%#DiagnosticWarn#W%d%%*", warn))
    end

    if hint > 0 then
        table.insert(parts, string.format("%%#DiagnosticHint#H%d%%*", hint))
    end

    if info > 0 then
        table.insert(parts, string.format("%%#DiagnosticInfo#I%d%%*", info))
    end

    return table.concat(parts, " ")
end

vim.opt.statusline = " %{expand('%:.')}%4( %m%) %{%v:lua._status_line_git()%} %="
    .. " %{%v:lua._status_line_diagnostics()%} "
    .. " %{&filetype}  %-6.6{&fileencoding}"
    .. " %-4.4{&fileformat} %4.4(%p%%%)%6.6l:%-3.3v"

function _G._quickfix_text_func(info)
    local items
    if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 1 }).items
    else
        items = vim.fn.getloclist(info.winid, { id = info.id, items = 1 }).items
    end

    local lines = {}
    for i = info.start_idx, info.end_idx do
        local item = items[i]
        local line = ""

        local name = ""
        if item.bufnr ~= 0 then
            name = vim.fn.fnamemodify(vim.fn.bufname(item.bufnr), ":.")
        end
        if vim.fn.strchars(name) == 0 then
            name = "  "
        end
        line = line .. name

        if item.lnum > 0 then
            line = line .. ":" .. item.lnum
            if item.col > 0 then
                line = line .. ":" .. item.col
            end
            line = line .. ": "
        end

        line = line .. item.text
        table.insert(lines, line)
    end

    return lines
end

vim.cmd([[
    syntax on
    filetype plugin indent on

    function! QuickfixTextFunc(info) abort
        return v:lua._quickfix_text_func(a:info)
    endfunction

    set quickfixtextfunc=QuickfixTextFunc
]])

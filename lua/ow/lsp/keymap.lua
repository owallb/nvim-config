local util = require("ow.util")

---@class Keymap
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field opts? vim.keymap.set.Opts

local M = {}

---@param bufnr integer
---@param keymaps Keymap[]
function M.set(bufnr, keymaps)
    for _, keymap in ipairs(keymaps) do
        keymap.opts = vim.tbl_extend(
            "force",
            keymap.opts or {},
            { buffer = bufnr, remap = true }
        )
        vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
    end
end

---@param bufnr integer
function M.set_defaults(bufnr)
    ---@type Keymap[]
    local keymaps = {
        { mode = { "n" }, lhs = "<leader>df", rhs = vim.diagnostic.open_float },
        {
            mode = { "n" },
            lhs = "[d",
            rhs = function()
                vim.diagnostic.jump({ count = -1, float = true })
            end,
        },
        {
            mode = { "n" },
            lhs = "]d",
            rhs = function()
                vim.diagnostic.jump({ count = 1, float = true })
            end,
        },
        { mode = { "n" }, lhs = "gD", rhs = vim.lsp.buf.declaration },
        {
            mode = { "n", "i" },
            lhs = "<C-k>",
            rhs = function()
                vim.lsp.buf.hover({ border = "rounded", max_width = 80 })
            end,
        },
        {
            mode = { "n", "i" },
            lhs = "<C-j>",
            rhs = function()
                vim.lsp.buf.signature_help({ border = "rounded", max_width = 80 })
            end,
        },
        {
            mode = { "n", "i" },
            lhs = "<C-h>",
            rhs = vim.lsp.buf.document_highlight,
        },
        { mode = { "n", "x" }, lhs = "<leader>lf", rhs = vim.lsp.buf.format },
        {
            mode = { "n" },
            lhs = "<leader>ld",
            rhs = function()
                vim.diagnostic.enable(not vim.diagnostic.is_enabled())
            end,
        },
        {
            mode = { "n", "i" },
            lhs = "<C-l>",
            rhs = function()
                vim.lsp.buf.clear_references()
                vim.cmd.nohlsearch()
                vim.schedule(vim.cmd.diffupdate)
                return "<C-l>"
            end,
            opts = { expr = true },
        },
    }

    local telescope = util.try_require("telescope.builtin")

    if telescope then
        vim.list_extend(keymaps, {
            { mode = "n", lhs = "<leader>dl", rhs = telescope.diagnostics },
            { mode = "n", lhs = "grt", rhs = telescope.lsp_type_definitions, },
            { mode = "n", lhs = "gd", rhs = telescope.lsp_definitions },
            { mode = "n", lhs = "gri", rhs = telescope.lsp_implementations },
            { mode = "n", lhs = "grr", rhs = telescope.lsp_references },
        })
    else
        vim.list_extend(keymaps, {
            { mode = "n", lhs = "<leader>dl", rhs = vim.diagnostic.setloclist },
            { mode = "n", lhs = "grt", rhs = vim.lsp.buf.type_definition, },
            { mode = "n", lhs = "gd", rhs = vim.lsp.buf.definition },
        })
    end

    M.set(bufnr, keymaps)
end

return M

-- Mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions

local utils = require("utils")

---@class Keymap
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field opts? vim.keymap.set.Opts

local MODE_TYPES = { "n", "v", "s", "x", "o", "i", "l", "c" }

local M = {}

---@type table<number, vim.api.keyset.keymap[]>
M.old = {}

---@type table<number, Keymap[]>
M.new = {}

--- Load LSP keybinds
---@param server Server
function M:init(server, bufnr)
    self.old[bufnr] = {}
    for _, mode in ipairs(MODE_TYPES) do
        vim.tbl_extend("error", self.old[bufnr], vim.api.nvim_buf_get_keymap(bufnr, mode))
    end

    self.new[bufnr] = {
        { mode = { "n" }, lhs = "<leader>df", rhs = vim.diagnostic.open_float },
        { mode = { "n" }, lhs = "[d", rhs = vim.diagnostic.goto_prev },
        { mode = { "n" }, lhs = "]d", rhs = vim.diagnostic.goto_next },
        { mode = { "n" }, lhs = "gD", rhs = vim.lsp.buf.declaration },
        { mode = { "n", "i" }, lhs = "<C-k>", rhs = vim.lsp.buf.hover },
        { mode = { "n", "i" }, lhs = "<C-j>", rhs = vim.lsp.buf.signature_help },
        { mode = { "n", "i" }, lhs = "<C-h>", rhs = vim.lsp.buf.document_highlight },
        { mode = { "n" }, lhs = "<leader>lr", rhs = vim.lsp.buf.rename },
        { mode = { "n" }, lhs = "<leader>la", rhs = vim.lsp.buf.code_action },
        { mode = { "n", "x" }, lhs = "<leader>lf", rhs = vim.lsp.buf.format },
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

    local telescope = utils.try_require("telescope.builtin")

    if telescope then
        vim.list_extend(self.new[bufnr], {
            { mode = "n", lhs = "<leader>dl", rhs = telescope.diagnostics },
            { mode = "n", lhs = "<leader>lD", rhs = telescope.lsp_type_definitions },
            { mode = "n", lhs = "gd", rhs = telescope.lsp_definitions },
            { mode = "n", lhs = "gi", rhs = telescope.lsp_implementations },
            { mode = "n", lhs = "gr", rhs = telescope.lsp_references },
        })
    else
        vim.list_extend(self.new[bufnr], {
            { mode = "n", lhs = "<leader>dl", rhs = vim.diagnostic.setloclist },
            { mode = "n", lhs = "<leader>ld", rhs = vim.lsp.buf.type_definition },
            { mode = "n", lhs = "gd", rhs = vim.lsp.buf.definition },
            { mode = "n", lhs = "gi", rhs = vim.lsp.buf.implementation },
            { mode = "n", lhs = "gr", rhs = vim.lsp.buf.references },
        })
    end

    if server.config.keymaps then
        vim.list_extend(self.new[bufnr], server.config.keymaps)
    end

    for _, keymap in ipairs(self.new[bufnr]) do
        keymap.opts = vim.tbl_extend("force", keymap.opts or {}, { buffer = bufnr, remap = true })
        vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
    end
end

function M:deinit(bufnr)
    if self.new[bufnr] then
        for _, keymap in ipairs(self.new[bufnr]) do
            -- pcall to avoid error if keymap was already removed,
            -- for example if server.config.keymaps overrides a default LSP keymap
            pcall(vim.keymap.del, keymap.mode, keymap.lhs, { buffer = bufnr })
        end
        self.new[bufnr] = nil
    end

    if self.old[bufnr] then
        for _, keymap in ipairs(self.old[bufnr]) do
            vim.cmd.mapset(keymap)
        end
        self.old[bufnr] = nil
    end
end

return M

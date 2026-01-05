---@type fun(name: string, cfg: vim.lsp.Config)
vim.lsp.config = vim.lsp.config

local log = require("log")
local util = require("util")

local M = {}

M.diagnostic_signs = {
    text = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
    },
}

---@param bufnr integer
local function set_keymaps(bufnr)
    local keymaps = {
        { mode = { "n" }, lhs = "<leader>dk", rhs = vim.diagnostic.open_float },
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
            mode = "n",
            lhs = "K",
            rhs = function()
                vim.lsp.buf.hover({ max_width = 80 })
            end,
        },
        {
            mode = { "i", "s" },
            lhs = "<C-s>",
            rhs = function()
                vim.lsp.buf.signature_help({ max_width = 80 })
            end,
        },
        {
            mode = { "n", "i" },
            lhs = "<C-h>",
            rhs = vim.lsp.buf.document_highlight,
        },
        {
            mode = { "n", "x" },
            lhs = "<leader>lf",
            rhs = vim.lsp.buf.format,
        },
        {
            mode = { "n" },
            lhs = "<leader>ld",
            rhs = function()
                vim.diagnostic.enable(
                    not vim.diagnostic.is_enabled({ bufnr = bufnr }),
                    { bufnr = bufnr }
                )
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
            { mode = "n", lhs = "grt", rhs = telescope.lsp_type_definitions },
            { mode = "n", lhs = "gd", rhs = telescope.lsp_definitions },
            { mode = "n", lhs = "gri", rhs = telescope.lsp_implementations },
            { mode = "n", lhs = "grr", rhs = telescope.lsp_references },
        })
    else
        vim.list_extend(keymaps, {
            { mode = "n", lhs = "<leader>dl", rhs = vim.diagnostic.setloclist },
            { mode = "n", lhs = "grt", rhs = vim.lsp.buf.type_definition },
            { mode = "n", lhs = "gd", rhs = vim.lsp.buf.definition },
        })
    end

    for _, keymap in ipairs(keymaps) do
        keymap.opts =
        vim.tbl_extend("keep", keymap.opts or {}, { buffer = bufnr })
        vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts)
    end
end

--- Load a JSON file and return a parsed table merged with settings
---@param path string
---@param settings? table
---@return table?
local function with_file(path, settings)
    local file = io.open(path, "r")
    if not file then
        return
    end

    local json = file:read("*all")
    file:close()
    local ok, resp = pcall(
        vim.json.decode,
        json,
        { luanil = { object = true, array = true } }
    )
    if not ok then
        log.warning("Failed to parse json file %s: %s", path, resp)
        return
    end

    return vim.tbl_deep_extend("force", settings or {}, resp)
end

function M.on_attach(client, bufnr)
    set_keymaps(bufnr)

    client.settings = with_file(
        string.format(".%s.json", client.name),
        client.settings
    ) or client.settings
end

function M.setup()
    vim.diagnostic.config({
        underline = true,
        signs = M.diagnostic_signs,
        virtual_text = false,
        float = {
            show_header = false,
            source = true,
            border = "rounded",
            focusable = true,
            format = function(diagnostic)
                return string.format("%s", diagnostic.message)
            end,
            width = 80,
        },
        update_in_insert = false,
        severity_sort = true,
        jump = {
            float = true,
            wrap = false,
        },
    })

    vim.lsp.enable({
        "bashls",
        "clangd",
        "cmake",
        "gopls",
        -- "hyprls",
        "intelephense",
        -- "jedi_language_server",
        "lemminx",
        "lua_ls",
        "mesonlsp",
        -- "phpactor",
        -- "pyrefly",
        "pyright",
        "ruff",
        "rust_analyzer",
        "zls",
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
        "force",
        capabilities,
        require("blink.cmp").get_lsp_capabilities({}, false)
    )
    vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = M.on_attach,
    })
end

return M

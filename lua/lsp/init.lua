--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local package_name = "lsp"
local utils = require("utils")

local P = {}

P._filetypes = nil
P._language_servers = nil

P.capabilities = {}

P.config = {
    bashls = {},
    clangd = {},
    cmake = {},
    diagnosticls = {},
    jedi_language_server = {},
    lemminx = {},
    lua_ls = {},
    phpactor = {},
    intelephense = {},
}

for server, _ in pairs(P.config) do
    local ok, resp = pcall(require, "lsp.config." .. server)
    if not ok then
        return
    end
    P.config[server] = resp
end

local function ca_rename()
    local old = vim.fn.expand("<cword>")
    local new
    vim.ui.input(
        { prompt = ("Rename `%s` to: "):format(old), },
        function (input)
            new = input
        end
    )
    if new and new ~= "" then
        vim.lsp.buf.rename(new)
    end
end

function P._setup_diagnostics()
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#customizing-how-diagnostics-are-displayed
    vim.diagnostic.config({
        underline = true,
        signs = true,
        virtual_text = {
            prefix = "",
            format = function (diagnostic)
                return diagnostic.message
            end,
        },
        float = {
            show_header = false,
            source = "always",
            border = "rounded",
            focusable = false,
            format = function (diagnostic)
                return string.format("%s", diagnostic.message)
            end,
        },
        update_in_insert = false,
        severity_sort = false,
    })
    local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " ", }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl, })
    end
end

function P.on_attach(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { silent = true, buffer = bufnr, }
    vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set({ "n", "i", }, "<C-k>", vim.lsp.buf.hover, opts)
    vim.keymap.set({ "n", "i", }, "<C-j>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set({ "n", "i", }, "<C-h>", vim.lsp.buf.document_highlight, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>lr", ca_rename, opts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set(
        { "n", "x", },
        "<leader>lf",
        function ()
            vim.lsp.buf.format({ async = false, })
        end,
        opts
    )

    -- For document highlight
    vim.fn.execute("hi! link LspReferenceRead Visual")
    vim.fn.execute("hi! link LspReferenceText Visual")
    vim.fn.execute("hi! link LspReferenceWrite Visual")
    -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
    --     buffer = bufnr,
    --     callback = vim.lsp.buf.document_highlight,
    -- })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", }, {
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })

    vim.opt.updatetime = 300
end

function P.reload_server_buf(self, name)
    local server = self.config[name]
    local ft_map = {}
    for _, ft in ipairs(server.lspconfig.filetypes) do
        ft_map[ft] = true
    end
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local buf_ft = vim.api.nvim_get_option_value(
                "filetype",
                { buf = bufnr, }
            )
            if ft_map[buf_ft] then
                vim.api.nvim_buf_call(
                    bufnr,
                    function () vim.cmd("e") end
                )
            end
        end
    end
end

function P.filetypes(self)
    if not self._filetypes then
        self._filetypes = {}
        local unique = {}
        for _, server in pairs(self.config) do
            for _, ft in ipairs(server.lspconfig.filetypes) do
                if not unique[ft] then
                    table.insert(self._filetypes, ft)
                    unique[ft] = true
                end
            end
        end
    end

    return self._filetypes
end

function P.language_servers(self)
    if not self._language_servers then
        self._language_servers = {}
        for server, opts in pairs(self.config) do
            if opts.enabled ~= true then
                goto next_server
            end
            if opts.dependencies ~= nil then
                local not_installed = {}
                for _, dep in ipairs(opts.dependencies) do
                    if not utils.is_installed(dep) then
                        table.insert(not_installed, dep)
                    end
                end

                if #not_installed > 0 then
                    utils.warn(
                        ("Disabling %s "
                            + "because the following required package(s) "
                            + "are not installed: %s")
                        :format(
                            server,
                            table.concat(not_installed, ", ")
                        ),
                        package_name
                    )
                    opts.enabled = false
                    goto next_server
                end
            end

            if opts.py_module_deps ~= nil then
                local not_installed = {}
                for _, mod in ipairs(opts.py_module_deps) do
                    if not utils.python3_module_is_installed(mod) then
                        table.insert(not_installed, mod)
                    end
                end

                if #not_installed > 0 then
                    utils.warn(
                        ("Disabling %s "
                            + "because the following required python3 "
                            + "module(s) are not installed: %s")
                        :format(
                            server,
                            table.concat(not_installed, ", ")
                        ),
                        package_name
                    )
                    opts.enabled = false
                    goto next_server
                end
            end

            table.insert(self._language_servers, server)

            ::next_server::
        end
    end

    return self._language_servers
end

function P.setup_server(self, name)
    local server = self.config[name]

    if not server or server.enabled ~= true then
        return
    end

    local ok, lspconfig = pcall(require, "lspconfig")
    if not ok then
        utils.err("Missing required plugin lspconfig", package_name)
        return
    end

    server.lspconfig.root_dir = lspconfig.util.find_git_ancestor
    server.lspconfig.capabilities = self.capabilities
    server.lspconfig.on_attach = function (...)
        local resp
        ok, resp = pcall(self.on_attach, ...)
        if not ok then
            utils.err(
                ("Failed to load on_attach for %s:\n%s"):format(name, resp)
            )
        end
    end

    if not pcall(lspconfig[name].setup, server.lspconfig) then
        utils.err("Unknown LSP server for lspconfig: " .. name, package_name)
        return
    end

    self:reload_server_buf(name)
end

function P.setup(self)
    self._setup_diagnostics()

    utils.try_require("cmp_nvim_lsp", package_name, function (mod)
        P.capabilities = mod.default_capabilities()
    end)

    utils.try_require("mason-lspconfig", package_name, function (mod)
        mod.setup_handlers({
            function (name)
                self:setup_server(name)
            end,
        })
    end)
end

return P

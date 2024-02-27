local module_name = "lsp"
local utils = require("utils")

local M = {}

local _filetypes = nil
-- local auto_installed_servers = nil

local capabilities = {}

local config = {
    bashls = {},
    clangd = {},
    cmake = {},
    diagnosticls = {},
    gopls = {},
    groovyls = {},
    intelephense = {},
    jedi_language_server = {},
    lemminx = {},
    lua_ls = {},
    rust_analyzer = {},
    zls = {},
}

for server, _ in pairs(config) do
    utils.try_require("lsp." .. server, module_name, function (mod)
        config[server] = mod
    end)
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

local function setup_diagnostics()
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
            border = "single",
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

local function on_attach(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = bufnr, }
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
            if vim.bo.filetype ~= "php" then
                return vim.lsp.buf.format()
            end

            local dls = require("lsp.diagnosticls")
            local formatters = dls.lspconfig.init_options.formatFiletypes.php
            for _, fmt in ipairs(formatters) do
                if fmt == "php_cs_fixer" then
                    ---@type table
                    local winview = vim.fn.winsaveview()
                    vim.cmd.write({ bang = true, })
                    vim.lsp.buf.format()
                    vim.cmd.write({ bang = true, })
                    vim.fn.winrestview(winview)
                    return
                end
            end

            return vim.lsp.buf.format()
        end,
        opts
    )

    -- For document highlight
    vim.cmd.highlight({ "link LspReferenceRead Visual", bang = true, })
    vim.cmd.highlight({ "link LspReferenceText Visual", bang = true, })
    vim.cmd.highlight({ "link LspReferenceWrite Visual", bang = true, })
    -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
    --     buffer = bufnr,
    --     callback = vim.lsp.buf.document_highlight,
    -- })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", }, {
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })

    -- Auto show signature on insert in function parameters
    -- if client.server_capabilities.signatureHelpProvider then
    --     local chars = client.server_capabilities.signatureHelpProvider
    --         .triggerCharacters
    --     if chars and #chars > 0 then
    --         vim.api.nvim_create_autocmd("CursorHoldI", {
    --             buffer = bufnr,
    --             callback = vim.lsp.buf.signature_help,
    --         })
    --     end
    -- end

    vim.opt.updatetime = 300

    require("lsp-inlayhints").on_attach(client, bufnr, false)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
            border = "single",
        }
    )
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
            border = "single",
        }
    )
end

local function reload_server_buf(name)
    local server = config[name]
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
                    vim.cmd.edit
                )
            end
        end
    end
end


local function configure_server(name, server)
    local ok, ret = pcall(require, "lspconfig")
    if not ok then
        utils.err("Missing required plugin lspconfig", module_name)
        return
    end
    local lspconfig = ret

    if server.root_pattern then
        server.lspconfig.root_dir = lspconfig.util.root_pattern(
            unpack(server.root_pattern)
        )
    else
        server.lspconfig.root_dir = lspconfig.util.find_git_ancestor
    end
    server.lspconfig.capabilities = capabilities
    server.lspconfig.on_attach = function (...)
        ok, ret = pcall(on_attach, ...)
        if not ok then
            utils.err(
                ("Failed to load on_attach for %s:\n%s"):format(name, ret),
                module_name
            )
        end
    end

    ok, ret = pcall(lspconfig[name].setup, server.lspconfig)
    if not ok then
        utils.err(
            ("Failed to setup LSP server %s with lspconfig: %s"):format(
                name,
                ret
            ),
            module_name
        )
        return
    end

    reload_server_buf(name)
end

local function setup_server(name, server)
    local registry = require("mason-registry")
    local pkg_name

    if server.mason then
        pkg_name = server.mason.name
    end

    if (pkg_name and not registry.is_installed(pkg_name)) then
        local pkg = registry.get_package(pkg_name)
        local handle = pkg:install({ version = server.mason.version, })
        utils.info("Installing " .. pkg_name)
        local err
        handle:on("stderr", vim.schedule_wrap(function (msg)
            err = (err or "") .. msg
        end))
        handle:once("closed", vim.schedule_wrap(function ()
            if err then
                utils.err(err, module_name)
            end

            if pkg:is_installed() then
                utils.info("Installation finished for " .. pkg_name)
                configure_server(name, server)
            else
                utils.err("Installation failed for " .. pkg_name)
                server.enable = false
            end
        end))
    else
        if vim.fn.executable(server.lspconfig.cmd[1]) == 1 then
            configure_server(name, server)
        else
            utils.info(name .. " not installed, disabling", module_name)
            server.enable = false
        end
    end
end

local function register_server(name, server)
    local augroup = vim.api.nvim_create_augroup("LSP-" .. name, {})
    vim.api.nvim_create_autocmd("FileType", {
        once = true,
        pattern = table.concat(server.lspconfig.filetypes, ","),
        callback = vim.schedule_wrap(function ()
            setup_server(name, server)
            vim.api.nvim_del_augroup_by_id(augroup)
        end),
        group = augroup,
    })
end

function M.filetypes()
    if not _filetypes then
        _filetypes = {}
        local unique = {}
        for _, server in pairs(config) do
            for _, ft in ipairs(server.lspconfig.filetypes) do
                if not unique[ft] then
                    table.insert(_filetypes, ft)
                    unique[ft] = true
                end
            end
        end
    end

    return _filetypes
end

function M.setup()
    setup_diagnostics()

    utils.try_require("cmp_nvim_lsp", module_name, function (mod)
        capabilities = mod.default_capabilities()
    end)

    for name, server in pairs(config) do
        if server.enable then
            register_server(name, server)
        end
    end
end

return M

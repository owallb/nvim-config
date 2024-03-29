local module_name = "lsp"
local utils = require("utils")

local M = {}

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

local function ca_rename_fallback()
    local old = vim.fn.expand("<cword>")
    vim.ui.input(
        { prompt = ("Rename `%s` to: "):format(old), },
        function (input)
            if input ~= "" then
                vim.lsp.buf.rename(input)
            end
        end
    )
end

local function ca_rename()
    local ts_utils = utils.try_require("nvim-treesitter.ts_utils", module_name)
    if not ts_utils then
        return ca_rename_fallback()
    end

    local node = ts_utils.get_node_at_cursor()
    if not node or node:type() ~= "IDENTIFIER" then
        utils.info("Only identifiers may be renamed", module_name)
        return
    end

    vim.lsp.buf.document_highlight()

    local old = vim.fn.expand("<cword>")
    local buf = vim.api.nvim_create_buf(false, true)
    local min_width = 10
    local max_width = 50
    local default_width = math.min(
        max_width,
        math.max(min_width, vim.str_utfindex(old) + 1)
    )
    local row, col, _, _ = node:range()
    local win = vim.api.nvim_open_win(
        buf,
        true,
        {
            relative = "win",
            anchor = "NW",
            width = default_width,
            height = 1,
            bufpos = { row, col - 1, },
            focusable = true,
            zindex = 50,
            style = "minimal",
            border = "rounded",
            title = "Rename",
            title_pos = "center",
        }
    )

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { old, })

    vim.api.nvim_create_autocmd(
        { "TextChanged", "TextChangedI", "TextChangedP", }, {
            buffer = buf,
            callback = function ()
                local win_width = vim.api.nvim_win_get_width(win)
                local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                if #content > 0 then
                    local cwidth = vim.str_utfindex(content[1] or "") + 1
                    local new_width = math.min(
                        max_width,
                        math.max(min_width, cwidth)
                    )
                    if new_width ~= win_width then
                        vim.api.nvim_win_set_width(win, new_width)
                    end
                end
            end,
        })

    vim.keymap.set(
        { "n", "i", "x", },
        "<cr>",
        function ()
            local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            vim.api.nvim_win_close(win, true)
            vim.cmd.stopinsert()
            if #content > 0 then
                local new_name = content[1]
                vim.lsp.buf.rename(new_name)
            end
        end,
        { buffer = buf, }
    )
    vim.keymap.set(
        { "n", "i", "x", },
        "<C-c>",
        function ()
            vim.api.nvim_win_close(win, true)
            vim.cmd.stopinsert()
        end,
        { buffer = buf, }
    )
    vim.keymap.set(
        { "n", "x", },
        "<esc>",
        function ()
            vim.api.nvim_win_close(win, true)
        end,
        { buffer = buf, }
    )
    vim.keymap.set(
        { "n", "x", },
        "q",
        function ()
            vim.api.nvim_win_close(win, true)
        end,
        { buffer = buf, }
    )

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("^v$<C-g>", true, false, true),
        "n",
        true
    )
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
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set({ "n", "i", }, "<C-k>", vim.lsp.buf.hover, opts)
    vim.keymap.set({ "n", "i", }, "<C-j>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set({ "n", "i", }, "<C-h>", vim.lsp.buf.document_highlight, opts)
    vim.keymap.set("n", "<leader>lr", ca_rename, opts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set(
        { "n", "x", },
        "<leader>lf",
        vim.lsp.buf.format,
        opts
    )

    ---@module "telescope.builtin"
    local telescope = utils.try_require("telescope.builtin", module_name)
    if telescope then
        vim.keymap.set("n", "<leader>dl", telescope.diagnostics, opts)
        vim.keymap.set("n", "<leader>lD", telescope.lsp_type_definitions, opts)
        vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
        vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)
        vim.keymap.set("n", "gr", telescope.lsp_references, opts)
    else
        vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
        vim.keymap.set("n", "<leader>ld", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    end

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

local function get_missing_deps(server)
    local missing_deps = {}

    if server.dependencies ~= nil then
        for _, dep in ipairs(server.dependencies) do
            if not utils.is_installed(dep) then
                table.insert(missing_deps, dep)
            end
        end
    end

    if server.py_module_deps ~= nil then
        for _, mod in ipairs(server.py_module_deps) do
            if not utils.python3_module_is_installed(mod) then
                table.insert(missing_deps, "python3-" .. mod)
            end
        end
    end

    return missing_deps
end

local function setup_server(name, server)
    local missing_deps = get_missing_deps(server)
    if #missing_deps > 0 then
        utils.warn(
            ("Disabling %s because the following package(s) "
                .. "are not installed: %s")
            :format(
                name,
                table.concat(missing_deps, ", ")
            ),
            module_name
        )
        server.enable = false
        return
    end

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
            utils.warn(name .. " not installed, disabling", module_name)
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

function M.setup()
    setup_diagnostics()

    capabilities = vim.lsp.protocol.make_client_capabilities()

    utils.try_require("cmp_nvim_lsp", module_name, function (cmp_nvim_lsp)
        capabilities = vim.tbl_deep_extend(
            "force", capabilities,
            cmp_nvim_lsp.default_capabilities()
        )
    end)

    for name, server in pairs(config) do
        if server.enable then
            register_server(name, server)
        end
    end
end

return M

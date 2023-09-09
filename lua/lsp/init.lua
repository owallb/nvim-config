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

P.servers = {
    bashls = {},
    clangd = {},
    cmake = {},
    diagnosticls = {},
    groovyls = {},
    jedi_language_server = {},
    lemminx = {},
    lua_ls = {},
}

for name, _ in pairs(P.servers) do
    P.servers[name] = require("lsp.config." .. name)
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

function P._setup_diagnostic()
    vim.diagnostic.config({
        underline = true,
        signs = true,
        virtual_text = false,
        -- virtual_text = {
        --     format = function(diagnostic)
        --         return string.format("%s: %s", diagnostic.user_data.lsp.code, diagnostic.message)
        --     end
        -- },
        float = {
            show_header = false,
            source = "if_many",
            border = "rounded",
            focusable = false,
            format = function (diagnostic)
                return string.format("%s", diagnostic.message)
            end,

        },
        update_in_insert = false, -- default to false
        severity_sort = true,     -- default to false
    })
    -- Change diagnostic icons
    vim.fn.sign_define("DiagnosticSignError", {
        text = "E",
        texthl = "DiagnosticSignError",
        -- culhl = 'DiagnosticSignError',
        numhl = "DiagnosticSignError",
        -- linehl = 'LspDiagnosticsUnderlineError'
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text = "W",
        texthl = "DiagnosticSignWarn",
        -- culhl = 'DiagnosticSignWarn',
        numhl = "DiagnosticSignWarn",
        -- linehl = 'LspDiagnosticsUnderlineWarning'
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text = "H",
        texthl = "DiagnosticSignHint",
        -- culhl = 'DiagnosticSignHint',
        numhl = "DiagnosticSignHint",
        -- linehl = 'LspDiagnosticsUnderlineHint'
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
        text = "i",
        texthl = "DiagnosticSignInfo",
        -- culhl = 'DiagnosticSignInfo',
        numhl = "DiagnosticSignInfo",
        -- linehl = 'LspDiagnosticsUnderlineInfo'
    })

    -- Change some highlights
    -- vim.cmd('highlight DiagnosticUnderlineError guifg=' .. utils.get_hl('DiagnosticError').foreground)
    -- vim.cmd('highlight DiagnosticUnderlineWarn guifg=' .. utils.get_hl('DiagnosticWarn').foreground)
end

function P.on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- Disabled in favor of nvim-cmp
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    require("lsp_signature").on_attach({
        debug = false,                                              -- set to true to enable debug logging
        log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
        -- default is  ~/.cache/nvim/lsp_signature.log
        verbose = false,                                            -- show debug line number

        bind = true,                                                -- This is mandatory, otherwise border config won't get registered.
        -- If you want to hook lspsaga or other signature handler, pls set to false
        doc_lines = 20,                                             -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
        -- set to 0 if you DO NOT want any API comments be shown
        -- This setting only take effect in insert mode, it does not affect signature help in normal
        -- mode, 10 by default

        max_height = 12,                       -- max height of signature floating_window
        max_width = 80,                        -- max_width of signature floating_window
        noice = false,                         -- set to true if you using noice to render markdown
        wrap = true,                           -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long

        floating_window = true,                -- show hint in a floating window, set to false for virtual text only mode

        floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
        -- will set to true when fully tested, set to false will use whichever side has more space
        -- this setting will be helpful if you do not want the PUM and floating win overlap

        floating_window_off_x = 1, -- adjust float windows x position.
        floating_window_off_y = 0, -- adjust float windows y position. e.g -2 move window up 2 lines; 2 move down 2 lines

        close_timeout = nil, -- close floating window after ms when laster parameter is entered
        fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
        hint_enable = false, -- virtual hint enable
        hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
        hint_scheme = "String",
        hi_parameter = "IncSearch", -- default 'LspSignatureActiveParameter', -- how your parameter will be highlight
        handler_opts = {
            border = "none", -- double, rounded, single, shadow, none
        },

        always_trigger = true,      -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

        auto_close_after = nil,     -- autoclose signature float win after x sec, disabled if nil.
        extra_trigger_chars = {},   -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
        zindex = 200,               -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

        padding = "",               -- character to pad on left and right of signature can be ' ', or '|'  etc

        transparency = nil,         -- disabled by default, allow floating win transparent value 1~100
        shadow_blend = 36,          -- if you using shadow as border use this set the opacity
        shadow_guibg = "Black",     -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
        timer_interval = 200,       -- default timer check interval set to lower value if you want to reduce latency
        toggle_key = "<C-e>",       -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'

        select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
        move_cursor_key = "<C-s>",  -- imap, use nvim_set_current_win to move cursor between current win and floating
    }, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { silent = true, buffer = bufnr, }
    vim.keymap.set("n", "L", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>ll", vim.diagnostic.setloclist, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>s", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function () print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    -- vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", ca_rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set({ "n", "v", }, "<leader>lf", function () vim.lsp.buf.format({ async = true, }) end, opts)
    -- if client.server_capabilities.document_range_formatting then
    -- end

    -- The below command will highlight the current variable and its usages in the buffer.
    if client.server_capabilities.document_highlight then
        vim.fn.execute("hi! link LspReferenceRead Visual")
        vim.fn.execute("hi! link LspReferenceText Visual")
        vim.fn.execute("hi! link LspReferenceWrite Visual")
        vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true, })
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
    -- Auto show current line diagnostics after 300 ms
    -- vim.cmd('autocmd CursorHold <buffer> lua vim.diagnostic.open_float({ scope = "line" })')
    -- vim.api.nvim_create_autocmd("CursorHold", {
    --     buffer = bufnr,
    --     callback = function()
    --         vim.diagnostic.open_float({ scope = "line" })
    --     end
    -- })
    vim.opt.updatetime = 100
end

function P.reload_server_buf(self, name)
    local server = self.servers[name]
    local ft_map = {}
    for _, ft in ipairs(server.lspconfig.filetypes) do
        ft_map[ft] = true
    end
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr, })
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
        for _, server in pairs(self.servers) do
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
        for name, server in pairs(self.servers) do
            if server.enabled ~= true then
                goto next_server
            end
            if server.dependencies ~= nil then
                local not_installed = {}
                for _, dep in ipairs(server.dependencies) do
                    if not utils.is_installed(dep) then
                        table.insert(not_installed, dep)
                    end
                end

                if #not_installed > 0 then
                    utils.warn(
                        ("Disabling %s because the following required package(s) are not installed: %s"):format(
                            name,
                            table.concat(not_installed, ", ")
                        ),
                        package_name
                    )
                    server.enabled = false
                    goto next_server
                end
            end

            if server.py_module_deps ~= nil then
                local not_installed = {}
                for _, mod in ipairs(server.py_module_deps) do
                    if not utils.python3_module_is_installed(mod) then
                        table.insert(not_installed, mod)
                    end
                end

                if #not_installed > 0 then
                    utils.warn(
                        ("Disabling %s because the following required python3 module(s) are not installed: %s"):format(
                            name,
                            table.concat(not_installed, ", ")
                        ),
                        package_name
                    )
                    server.enabled = false
                    goto next_server
                end
            end

            table.insert(self._language_servers, name)

            ::next_server::
        end
    end

    return self._language_servers
end

function P.setup_server(self, name)
    local server = self.servers[name]

    if server.enabled ~= true then
        return
    end

    local lspconfig = require("lspconfig")
    server.lspconfig.root_dir = lspconfig.util.find_git_ancestor
    server.lspconfig.capabilities = self.capabilities
    server.lspconfig.on_attach = self.on_attach
    lspconfig[name].setup(server.lspconfig)
    self:reload_server_buf(name)
end

function P.setup(self)
    self._setup_diagnostic()
    P.capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("mason-lspconfig").setup_handlers({
        function (name)
            self:setup_server(name)
        end,
    })
end

return P

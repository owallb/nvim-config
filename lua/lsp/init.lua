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

local module_name = "lsp"
local utils = require("utils")

local P = {}

P._filetypes = nil
P._language_servers = nil

P.capabilities = {}

P.servers = require("lsp.servers")

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
    local opts = { noremap = true, silent = true, }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "L",
        "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "[d",
        "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "]d",
        "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ll",
        "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD",
        "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd",
        "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K",
        "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi",
        "<cmd>lua vim.lsp.buf.implementation()<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>s",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wa",
        "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wr",
        "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wl",
        "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gt",
        "<cmd>lua vim.lsp.buf.type_definition()<CR>",
        opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn",
        "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr",
        "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lf",
        "<cmd>lua vim.lsp.buf.format({async = true})<CR>",
        opts)
    -- if client.server_capabilities.document_range_formatting then
    vim.api.nvim_buf_set_keymap(bufnr, "v", "<leader>lf",
        "<cmd>lua vim.lsp.buf.format({async = true})<CR>",
        opts)
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
    for _, ft in ipairs(server.filetypes) do
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
        for _, cfg in pairs(self.servers) do
            for _, ft in ipairs(cfg.filetypes) do
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
        for name, opts in pairs(self.servers) do
            if opts.dependencies ~= nil then
                for _, dep in ipairs(opts.dependencies) do
                    if not utils.is_available(dep) then
                        utils.warn(
                            "Disabling " .. name .. " because " .. dep .. " is required but not installed",
                            module_name
                        )
                        opts.enabled = false
                        goto next_server
                    end
                end
            end

            if opts.enabled == true then
                opts.config = require("lsp.config." .. name)
                table.insert(self._language_servers, name)
            end
            ::next_server::
        end
    end

    return self._language_servers
end

function P.setup_server(self, name)
    local opts = self.servers[name]

    if opts.enabled ~= true then
        return
    end

    local lspconfig = require("lspconfig")
    opts.config.filetypes = opts.filetypes
    opts.config.root_dir = lspconfig.util.find_git_ancestor
    opts.config.capabilities = self.capabilities
    opts.config.on_attach = self.on_attach
    lspconfig[name].setup(opts.config)
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

local module_name = "lsp.server"
local utils = require("utils")

---@class MasonPackageConfig
local Package = require("lsp.package")

-- override type, seems to be incorrect in either lspconfig or vim.lsp
---@class lspconfig.Config
---@field root_dir function

---@class ServerConfig
---@field name string?
---@field enable boolean?
---@field dependencies string[]
---@field py_module_deps string[]
---@field mason MasonPackageConfig?
---@field root_patterns string[]?
---@field lspconfig lspconfig.Config
local M = {}
M.__index = M

--- Reload all buffers attached by a server
function M:reload_buffers()
    local ft_map = {}
    for _, ft in ipairs(self.lspconfig.filetypes) do
        ft_map[ft] = true
    end
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr, })
            if ft_map[buf_ft] then
                vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
            end
        end
    end
end

--- Rename Code Action
function M.ca_rename()
    local ts_utils = utils.try_require("nvim-treesitter.ts_utils", module_name)
    if not ts_utils then
        return
    end

    local identifier_types = { "IDENTIFIER", "identifier", "variable_name", "word", }

    local node = ts_utils.get_node_at_cursor()
    if not node or not utils.has_value(identifier_types, node:type()) then
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

--- Called when language server attaches
---@param client vim.lsp.Client
---@param bufnr integer
function M:on_attach(client, bufnr)
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
    vim.keymap.set("n", "<leader>lr", self.ca_rename, opts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set({ "n", "x", }, "<leader>lf", vim.lsp.buf.format, opts)

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
        vim.lsp.handlers.hover, { border = "single", }
    )
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = "single", }
    )
end

--- Configure the LSP client
function M:configure_client()
    local ok, ret = pcall(require, "lspconfig")
    if not ok then
        utils.err("Missing required plugin lspconfig", module_name)
        return
    end
    local lspconfig = ret

    if self.root_patterns then
        self.lspconfig.root_dir = lspconfig.util.root_pattern(unpack(self.root_patterns))
    else
        self.lspconfig.root_dir = lspconfig.util.find_git_ancestor
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    utils.try_require("cmp_nvim_lsp", module_name, function (cmp_nvim_lsp)
        capabilities = vim.tbl_deep_extend(
            "force",
            capabilities,
            cmp_nvim_lsp.default_capabilities()
        )
    end)
    self.lspconfig.capabilities = capabilities

    self.lspconfig.on_attach = function (...)
        ok, ret = pcall(self.on_attach, self, ...)
        if not ok then
            utils.err(
                ("Failed to load on_attach for %s:\n%s"):format(self.name, ret),
                module_name
            )
        end
    end

    ok, ret = pcall(lspconfig[self.name].setup, self.lspconfig)
    if not ok then
        utils.err(
            ("Failed to setup LSP server %s with lspconfig: %s"):format(self.name, ret),
            module_name
        )
        return
    end

    self:reload_buffers()
end

--- Check for and return missing dependencies
---@return table<string>
function M:get_missing_unmanaged_deps()
    local missing_deps = {}

    if self.dependencies ~= nil then
        for _, dep in ipairs(self.dependencies) do
            if not utils.is_installed(dep) then
                table.insert(missing_deps, dep)
            end
        end
    end

    if self.py_module_deps ~= nil then
        for _, mod in ipairs(self.py_module_deps) do
            if not utils.python3_module_is_installed(mod) then
                table.insert(missing_deps, "python3-" .. mod)
            end
        end
    end

    return missing_deps
end

--- Install LSP server
---@param on_done fun(success: boolean)?
function M:install(on_done)
    --- Handle install result
    ---@param success boolean
    local function handle_result(success)
        if not success then
            self.enable = false
        end

        if on_done then
            on_done(success)
        end
    end

    self.mason:install(handle_result)
end

--- Setup LSP server
function M:setup()
    local missing_deps = self:get_missing_unmanaged_deps()
    if #missing_deps > 0 then
        utils.warn(
            ("Disabling %s because the following package(s) are not installed: %s")
            :format(self.name, table.concat(missing_deps, ", ")),
            module_name
        )
        self.enable = false
        return
    end

    if self.mason then
        self:install(function (success)
            if success then
                self:configure_client()
            end
        end)
    else
        if vim.fn.executable(self.lspconfig.cmd[1]) == 1 then
            self:configure_client()
        else
            utils.warn(self.name .. " not installed, disabling", module_name)
            self.enable = false
        end
    end
end

--- Register autocmd for setting up LSP server upon entering a buffer of related filetype
function M:register()
    local augroup = vim.api.nvim_create_augroup("LSP-" .. self.name, {})
    vim.api.nvim_create_autocmd("FileType", {
        once = true,
        pattern = table.concat(self.lspconfig.filetypes, ","),
        callback = vim.schedule_wrap(function ()
            self:setup()
            vim.api.nvim_del_augroup_by_id(augroup)
        end),
        group = augroup,
    })
end

--- Create a new instance
---@param config ServerConfig
---@return ServerConfig
function M:new(config)
    config = config or {}

    if config.mason then
        config.mason = Package:new(config.mason)
    end

    setmetatable(config, self)
    return config
end

return M

local utils = require("utils")
local keymap = require("lsp.keymap")
---@class MasonPackage
local MasonPackage = require("lsp.package")
-- override type, seems to be incorrect in either lspconfig or vim.lsp
---@class lspconfig.Config
---@field root_dir function

---@class Server
---@field name string?
---@field mason MasonPackage?
---@field client vim.lsp.Client?
---@field attached_buffers number[]?
---@field manager lspconfig.Manager
---@field config ServerConfig
local M = {}
M.__index = M
---@class ServerConfig
---@field enable boolean?
---@field dependencies string[]?
---@field mason MasonPackageConfig?
---@field root_patterns string[]?
---@field keymaps Keymap[]?
---@field lspconfig lspconfig.Config?
M.config = {}
--- Validate ServerConfig
---@param config ServerConfig
---@return boolean
function M.validate(name, config)
    local ok, resp = pcall(vim.validate, { config = { config, { "table" } } })
    if ok then
        ok, resp = pcall(vim.validate, {
            enable = { config.enable, { "boolean" }, true },
            dependencies = {
                config.dependencies,
                function(f)
                    return utils.is_list_or_nil(f, "string")
                end, "list of strings or nil",
            },
            mason = {
                config.mason, function(f)
                if f == nil then return true end
                return MasonPackage.validate(f)
            end,
            },
            root_patterns = {
                config.root_patterns,
                function(f)
                    return utils.is_list_or_nil(f, "string")
                end, "list of strings or nil",
            },
            keymaps = {
                config.keymaps, function(f)
                if not f then return true end
                if not utils.is_list(f, "table") then
                    return false
                end
                for _, key in ipairs(f) do
                    local o, r = pcall(vim.validate, {
                        mode = { key.mode, { "s", "t" } },
                        lhs = { key.lhs, "s" },
                        rhs = { key.rhs, { "s", "f" } },
                        opts = { key.opts, "t", true },
                    })
                    if not o then
                        utils.err(("Invalid keymap:\n%s"):format(r))
                        return false
                    end
                end
                return true
            end, "list of keymaps",
            },
            lspconfig = { config.lspconfig, { "table" }, true },
        })
    end
    if not ok then
        utils.err(("Invalid config for %s:\n%s"):format(name, resp))
        return false
    end
    return true
end

--- Rename Code Action
function M.ca_rename()
    local ts_utils = utils.try_require("nvim-treesitter.ts_utils")
    if not ts_utils then return end
    local identifier_types = {
        "IDENTIFIER", "identifier", "variable_name", "word",
    }
    local node = ts_utils.get_node_at_cursor()
    if not node or not vim.list_contains(identifier_types, node:type()) then
        utils.info("Only identifiers may be renamed")
        return
    end
    vim.lsp.buf.document_highlight()

    local old = vim.fn.expand("<cword>")
    local buf = vim.api.nvim_create_buf(false, true)
    local min_width = 10
    local max_width = 50
    local default_width = math.min(max_width, math.max(min_width,
        vim.str_utfindex(old) + 1))
    local row, col, _, _ = node:range()
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        anchor = "NW",
        width = default_width,
        height = 1,
        bufpos = { row, col - 1 },
        focusable = true,
        zindex = 50,
        style = "minimal",
        border = "rounded",
        title = "Rename",
        title_pos = "center",
    })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { old })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" },
        {
            buffer = buf,
            callback = function()
                local win_width = vim.api.nvim_win_get_width(win)
                local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                if #content > 0 then
                    local cwidth = vim.str_utfindex(content[1] or "") + 1
                    local new_width = math.min(max_width,
                        math.max(min_width, cwidth))
                    if new_width ~= win_width then
                        vim.api.nvim_win_set_width(win, new_width)
                    end
                end
            end,
        })

    vim.keymap.set({ "n", "i", "x" }, "<cr>", function()
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.api.nvim_win_close(win, true)
        vim.cmd.stopinsert()
        if #content > 0 then
            local new_name = content[1]
            vim.lsp.buf.rename(new_name)
        end
    end, { buffer = buf })
    vim.keymap.set({ "n", "i", "x" }, "<C-c>", function()
        vim.api.nvim_win_close(win, true)
        vim.cmd.stopinsert()
    end, { buffer = buf })
    vim.keymap.set({ "n", "x" }, "<esc>",
        function() vim.api.nvim_win_close(win, true) end,
        { buffer = buf })
    vim.keymap.set({ "n", "x" }, "q",
        function() vim.api.nvim_win_close(win, true) end,
        { buffer = buf })

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("^v$<C-g>", true,
        false, true), "n", true)
end

--- Called when language server attaches
---@param client vim.lsp.Client
---@param bufnr integer
function M:on_attach(client, bufnr)
    if self.client and self.client.id ~= client.id then
        self.client.stop(true)
    end
    self.client = client
    self.attached_buffers = self.attached_buffers or {}
    table.insert(self.attached_buffers, bufnr)

    keymap:load(self, bufnr)

    -- For document highlight
    vim.cmd.highlight({ "link LspReferenceRead Visual", bang = true })
    vim.cmd.highlight({ "link LspReferenceText Visual", bang = true })
    vim.cmd.highlight({ "link LspReferenceWrite Visual", bang = true })

    vim.opt.updatetime = 300
    require("lsp-inlayhints").on_attach(client, bufnr, false)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

    ---@alias lsp.Client vim.lsp.Client
    -- require("lsp_compl").attach(client, bufnr, {
    --     server_side_fuzzy_completion = true,
    -- })
end

--- Configure the LSP client
function M:configure_client()
    local lspconfig = require("lspconfig")

    if self.config.root_patterns then
        self.config.lspconfig.root_dir =
            lspconfig.util.root_pattern(unpack(self.config.root_patterns))
    else
        self.config.lspconfig.root_dir = lspconfig.util.find_git_ancestor
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local cmp_nvim_lsp = utils.try_require("cmp_nvim_lsp")
    if cmp_nvim_lsp then
        capabilities = vim.tbl_deep_extend("force", capabilities,
            cmp_nvim_lsp.default_capabilities())
    end

    -- local epo = utils.try_require("epo")
    -- if epo then
    --     capabilities = vim.tbl_deep_extend(
    --         "force",
    --         capabilities,
    --         epo.register_cap()
    --     )
    -- end

    -- local lsp_compl = utils.try_require("lsp_compl")
    -- if lsp_compl then
    --     capabilities = vim.tbl_deep_extend("force", capabilities, lsp_compl.capabilities())
    -- end
    --

    self.config.lspconfig.capabilities = capabilities
    self.config.lspconfig.on_attach = function(client, bufnr)
        local ok, ret = pcall(self.on_attach, self, client, bufnr)
        if not ok then
            utils.err(
                ("Failed to load on_attach for %s:\n%s"):format(self.name, ret),
                "lsp.server:configure_client")
        end
    end
    local ok, ret = pcall(lspconfig[self.name].setup, self.config.lspconfig)
    if not ok then
        utils.err(("Failed to setup LSP server %s with lspconfig: %s"):format(
            self.name, ret))
        return
    end
    self.manager = lspconfig[self.name].manager
    for _, bufnr in ipairs(self:get_ft_buffers()) do
        self.manager:try_add_wrapper(bufnr)
    end
end

function M:get_ft_buffers()
    local filetypes = self.config.lspconfig.filetypes or {}
    if not vim.list_contains(filetypes, self.config.lspconfig.filetype) then
        table.insert(filetypes, self.config.lspconfig.filetype)
    end
    if #filetypes == 0 then
        return {}
    end
    return vim.tbl_filter(function(bufnr)
        return vim.list_contains(filetypes, vim.bo[bufnr].filetype)
    end, vim.api.nvim_list_bufs())
end

--- Check for and return missing dependencies
---@return table<string>
function M:get_missing_unmanaged_deps()
    local missing_deps = {}
    if self.config.dependencies ~= nil then
        for _, dep in ipairs(self.config.dependencies) do
            if not utils.is_executable(dep) then
                table.insert(missing_deps, dep)
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
        if not success then self.config.enable = false end
        if on_done then on_done(success) end
    end

    self.mason:install(handle_result)
end

--- Setup LSP server
function M:setup()
    local missing_deps = self:get_missing_unmanaged_deps()
    if #missing_deps > 0 then
        utils.warn(
            ("Disabling %s because the following package(s) are not installed: %s"):format(
                self.name, table.concat(missing_deps, ", ")))
        self.config.enable = false
        return
    end
    if self.mason then
        self:install(function(success)
            if success then self:configure_client() end
        end)
    elseif vim.fn.executable(self.config.lspconfig.cmd[1]) == 1 then
        self:configure_client()
    else
        utils.warn(self.name .. " not installed, disabling")
        self.config.enable = false
    end
end

--- Register autocmd for setting up LSP server upon entering a buffer of related filetype
function M:register()
    local group = vim.api.nvim_create_augroup("lsp_bootstrap_" .. self.name, {})
    vim.api.nvim_create_autocmd("FileType", {
        once = true,
        pattern = self.config.lspconfig.filetypes or {},
        callback = function() self:setup() end,
        group = group,
    })
end

function M:unload()
    if self.attached_buffers then
        for _, bufnr in ipairs(self.attached_buffers) do
            keymap:unload(bufnr)
        end
    end
    if self.client then
        self.client.stop()
        self.client = nil
    end
    vim.api.nvim_clear_autocmds({ group = "lsp_bootstrap_" .. self.name })

    require("lspconfig")[self.name] = nil
end

--- Create a new instance
---@param name string
---@param config ServerConfig?
---@return Server?
function M.new(name, config)
    config = config or {}
    if not M.validate(name, config) then return end
    local ok, resp = pcall(require, "lspconfig.server_configurations." .. name)
    if not ok then
        utils.err(("Server with name %s does not exist in lspconfig"):format(
            name))
        return
    end
    config.lspconfig = vim.tbl_deep_extend("keep", config.lspconfig or {},
        resp.default_config)
    local server = { name = name, config = config }
    if server.config.mason then
        local pkg = MasonPackage.new(server.config.mason)
        if pkg then server.mason = pkg end
    end
    return setmetatable(server, M)
end

return M

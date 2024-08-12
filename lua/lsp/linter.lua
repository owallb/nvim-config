local utils = require("utils")

---@class Linter
---@field name string
---@field namespace number
---@field augroup number
---@field buffers number[]
---@field config LinterConfig
M = {}
M.__index = M

---@alias Group
---| "lnum"
---| "end_lnum"
---| "col"
---| "end_col"
---| "severity"
---| "message"
---| "source"
---| "code"

---@class LinterConfig
---@field cmd string[]
---@field stdin? boolean
---@field stdout? boolean
---@field stderr? boolean
---@field pattern string
---@field groups Group[]
---@field severity_map table<string, vim.diagnostic.Severity>
---@field source? string
---@field debounce? number
M.config = {}

function M.validate(name, config)
    local ok, resp = pcall(vim.validate, {
        name = { name, "string" },
        config = { config, "table" },
    })

    if ok then
        ok, resp = pcall(vim.validate, {
            cmd = {
                config.cmd,
                function(t)
                    return utils.is_list(t, "string")
                end,
                "list of strings",
            },
            stdin = { config.stdin, "boolean", true },
            stdout = { config.stdout, "boolean", true },
            stderr = { config.stderr, "boolean", true },
            pattern = { config.pattern, "string" },
            groups = {
                config.groups,
                function(t)
                    return utils.is_list(t, "string")
                end,
                "list of strings",
            },
            severity_map = {
                config.severity_map,
                function(t)
                    return utils.is_map(t, "string", "number")
                end,
                "map of string and number",
            },
            debounce = { config.debounce, "number", true },
            source = { config.source, "string", true },
        })
    end

    if not ok then
        utils.err(("Invalid config for linter:\n%s"):format(resp))
        return false
    end

    return true
end

function M:run(bufnr)
    local input
    -- TODO: add placeholder variables for when not using stdin
    if self.config.stdin then
        input = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    end

    local ok, resp = pcall(
        vim.system,
        self.config.cmd,
        { stdin = input },
        vim.schedule_wrap(function(out)
            local output
            if self.config.stdout then
                output = out.stdout or ""
            end
            if self.config.stderr then
                output = out.stderr or ""
            end

            local output_lines = vim.fn.split(output, "\n", false)
            local diagnostics = {}
            for _, line in ipairs(output_lines) do
                local ok, resp = pcall(
                    vim.diagnostic.match,
                    line,
                    self.config.pattern,
                    self.config.groups,
                    self.config.severity_map
                )
                if not ok then
                    utils.err(tostring(resp))
                    return
                elseif resp then
                    resp.source = resp.source or self.config.source
                    table.insert(diagnostics, resp)
                end
            end
            vim.diagnostic.set(self.namespace, bufnr, diagnostics)
        end)
    )

    if not ok then
        utils.err(("Failed to run %s:\n%s"):format(self.config.cmd[1], resp))
    end
end

function M:init(bufnr)
    table.insert(self.buffers, bufnr)
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = bufnr,
        callback = utils.debounce(function()
            self:run(bufnr)
        end, self.config.debounce),
        group = self.augroup,
    })
    self:run(bufnr)
end

function M:deinit()
    for _, bufnr in ipairs(self.buffers) do
        vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
    end
    self.buffers = {}

    vim.api.nvim_clear_autocmds({ group = self.augroup })
end

--- Create a new instance
---@param name string
---@param config LinterConfig
---@return Linter|nil
function M.new(name, config)
    if not M.validate(name, config) then
        return
    end

    config.debounce = config.debounce or 100

    local linter = {
        name = name,
        namespace = vim.api.nvim_create_namespace(name),
        augroup = vim.api.nvim_create_augroup(name, {}),
        buffers = {},
        config = config,
    }

    return setmetatable(linter, M)
end

return M

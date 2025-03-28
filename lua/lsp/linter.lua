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

---@class JsonConfig
---@field diagnostics_root? string
---@field lnum? string
---@field end_lnum? string
---@field col? string
---@field end_col? string
---@field severity? string
---@field message? string
---@field source? string
---@field code? string
---@field zero_idx? boolean
---@field callback? fun(diag: vim.Diagnostic)

---@class LinterConfig
---@field cmd string[]
---@field stdin? boolean
---@field stdout? boolean
---@field stderr? boolean
---@field pattern? string
---@field groups? Group[]
---@field severity_map? table<string, vim.diagnostic.Severity>
---@field source? string
---@field debounce? number
---@field json? JsonConfig
M.config = {}

-- Extract a value from a JSON object using a path
---@param obj table The JSON object
---@param path string Path to the value (dot notation string)
---@return any The value at the specified path, or nil if not found
function M.get_json_value(obj, path)
    if not obj then
        return nil
    end

    local current = obj
    local parts = {}

    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end

    for _, key in ipairs(parts) do
        if tonumber(key) ~= nil then
            key = tonumber(key)
        end

        if type(current) ~= "table" then
            return nil
        end

        current = current[key]
        if current == nil then
            return nil
        end
    end

    return current
end

function M:process_json_output(json, bufnr)
    local diagnostics = {}

    local items = json
    if self.config.json.diagnostics_root then
        items = M.get_json_value(json, self.config.json.diagnostics_root)
    end

    if type(items) ~= "table" then
        utils.err("diagnostics root is not an array or object")
        return
    end

    if not vim.islist(items) then
        items = { items }
    end

    for _, item in ipairs(items) do
        local diag = {}

        for field, path in pairs(self.config.json) do
            if field ~= "diagnostics_root" and field ~= "callback" then
                diag[field] = M.get_json_value(item, path)
            end
        end

        diag.source = diag.source or self.config.source

        if
            diag.severity
            and self.config.severity_map
            and self.config.severity_map[diag.severity]
        then
            diag.severity = self.config.severity_map[diag.severity]
        end

        if not self.config.json.zero_idx then
            if diag.lnum then
                diag.lnum = diag.lnum - 1
            end

            if diag.end_lnum then
                diag.end_lnum = diag.end_lnum - 1
            end

            if diag.col then
                diag.col = diag.col - 1
            end

            if diag.end_col then
                diag.end_col = diag.end_col - 1
            end
        end

        if diag.end_lnum and diag.end_col then
            local lines = vim.api.nvim_buf_get_lines(
                bufnr,
                diag.end_lnum,
                diag.end_lnum + 1,
                false
            )

            if #lines > 0 and #lines[1] > 0 then
                diag.end_col = math.min(diag.end_col, #lines[1] - 1)
            end
        end

        if type(self.config.json.callback) == "function" then
            self.config.json.callback(diag)
        end

        table.insert(diagnostics, diag)
    end

    return diagnostics
end

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
            pattern = { config.pattern, "string", true },
            groups = {
                config.groups,
                function(t)
                    return utils.is_list(t, "string")
                end,
                true,
                "list of strings",
            },
            severity_map = {
                config.severity_map,
                function(t)
                    return utils.is_map(t, "string", "number")
                end,
                true,
                "map of string and number",
            },
            debounce = { config.debounce, "number", true },
            source = { config.source, "string", true },
            json = { config.json, "table", true },
        })
    end

    if not ok then
        utils.err(("Invalid config for linter:\n%s"):format(resp))
        return false
    end

    if not config.json and (not config.pattern or not config.groups) then
        utils.err("Either json or pattern and groups must be provided")
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
        ---@param out vim.SystemCompleted
        vim.schedule_wrap(function(out)
            local output

            if self.config.stdout then
                output = out.stdout or ""
            end

            if self.config.stderr then
                output = out.stderr or ""
            elseif out.stderr and out.stderr ~= "" then
                utils.err(out.stderr)
            end

            if self.config.json then
                local ok, json = pcall(
                    vim.json.decode,
                    output,
                    { luanil = { object = true, array = true } }
                )
                if not ok then
                    utils.err("Failed to parse JSON: " .. json)
                    return
                end

                local diagnostics = self:process_json_output(json, bufnr)
                if diagnostics then
                    vim.diagnostic.set(self.namespace, bufnr, diagnostics)
                end

                return
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

                    local lines = vim.api.nvim_buf_get_lines(
                        bufnr,
                        resp.end_lnum,
                        resp.end_lnum + 1,
                        false
                    )

                    if #lines > 0 and #lines[1] > 0 then
                        resp.end_col = math.min(resp.end_col, #lines[1] - 1)
                    end

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

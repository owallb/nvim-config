local utils = require("utils")

---@class PostInstallStep
---@field command string
---@field args string[]

---@class MasonPackage
---@field dependencies MasonPackage[]?
---@field config MasonPackageConfig
local M = {}
M.__index = M

---@class MasonPackageConfig
---@field name string?
---@field version string?
---@field dependencies MasonPackageConfig[]?
---@field post_install PostInstallStep[]?
M.config = {}

--- Validate MasonPackageConfig
---@param config MasonPackageConfig
---@return boolean
function M.validate(config)
    local ok, resp = pcall(vim.validate, { config = { config, { "table" } } })
    if not ok then
        goto check_resp
    end

    ok, resp = pcall(
        vim.validate, {
            name = { config.name, { "string" }, true },
            version = { config.version, { "string" }, true },
            dependencies = {
                config.dependencies, function(f)
                if not f then
                    return true
                end

                if not utils.is_list(f) then
                    return false
                end

                for _, dep in ipairs(f) do
                    if not M.validate(dep) then
                        return false
                    end
                end

                return true
            end,
            },
            post_install = {
                config.post_install, function(field)
                if not field then
                    return true
                end

                if not utils.is_list(field) then
                    return false
                end

                for _, step in ipairs(field) do
                    local o, r = pcall(vim.validate, { step = { step, { "table" } } })
                    if not ok then
                        goto check_r
                    end

                    o, r = pcall(
                        vim.validate, {
                            command = { step.command, { "string" } },
                            args = {
                                step.args, function(f)
                                return utils.is_list_or_nil(f, "string")
                            end, "list of strings or nil",
                            },
                        }
                    )

                    ::check_r::

                    if not o then
                        utils.err(("Invalid config for post_install step: %s"):format(r))
                        return false
                    end

                    return true
                end

                return true
            end,
            },
        }
    )

    ::check_resp::
    if not ok then
        utils.err(("Invalid config for %s:\n%s"):format(config.name, resp))
        return false
    end

    return true
end

--- Run post installation steps
---@param pkg Package
function M:run_post_install(pkg)
    ---@param step PostInstallStep
    ---@param msg string
    local function log_err(step, msg)
        local cmd = step.command

        if step.args then
            cmd = cmd .. " " .. table.concat(step.args, " ")
        end

        utils.err(
            ("Post installation step for %s:\n`%s`\nfailed with:\n%s"):format(
                self.config.name, cmd, msg
            ), "lsp.package:run_post_install"
        )
    end

    if self.config.post_install then
        utils.info("running post install")
        for _, step in ipairs(self.config.post_install) do
            local cwd = pkg:get_install_path()
            local command = step.command

            if command:find("[/\\]") then
                command = vim.fn.resolve(("%s/%s"):format(cwd, command))
            end

            if not utils.is_executable(command) then
                log_err(step, "command not executable")
                return
            end

            local job = require("plenary.job"):new(
                {
                    command = step.command,
                    args = step.args,
                    cwd = pkg:get_install_path(),
                    enabled_recording = true,
                    on_exit = function(job, code, signal)
                        if code ~= 0 or signal ~= 0 then
                            local cmd = command
                            if step.args then
                                cmd = cmd .. " " .. table.concat(step.args, " ")
                            end

                            log_err(step, table.concat(job:stderr_result(), "\n"))
                        end
                    end,
                }
            )
            job:start()
        end
    end
end

--- Perform installation
---@param on_done fun(success: boolean)?
function M:mason_install(on_done)
    local registry = require("mason-registry")
    local ok, pkg = pcall(registry.get_package, self.config.name)
    if not ok then
        utils.err("Could not locate package " .. self.config.name)

        if on_done then
            on_done(false)
        end

        return
    end

    if pkg:is_installed() then
        if on_done then
            on_done(true)
        end

        return
    end

    utils.info(("Installing %s"):format(self.config.name))
    local handle = pkg:install({ version = self.config.version })

    local err
    handle:on(
        "stderr", vim.schedule_wrap(
            function(msg)
                err = (err or "") .. msg
            end
        )
    )

    handle:once(
        "closed", vim.schedule_wrap(
            function()
                local is_installed = pkg:is_installed()

                if is_installed then
                    utils.info(
                        ("Successfully installed %s"):format(self.config.name),
                        "lsp.package:mason_install"
                    )
                    self:run_post_install(pkg)
                else
                    if err then
                        err = ":\n" .. err
                    else
                        err = ""
                    end

                    utils.err(
                        ("Failed to install %s%s"):format(self.config.name, err),
                        "lsp.package:mason_install"
                    )
                end

                if on_done then
                    on_done(is_installed)
                end
            end
        )
    )
end

--- Install package dependencies
---@param on_done fun(success: boolean)?
function M:install_dependencies(on_done)
    if not self.dependencies or #self.dependencies == 0 then
        if on_done then
            on_done(true)
        end

        return
    end

    local total = #self.dependencies
    local completed = 0
    local all_successful = true

    --- Handle install result
    ---@param success boolean
    local function handle_result(success)
        completed = completed + 1

        if not success then
            all_successful = false
        end

        if completed == total and on_done then
            on_done(all_successful)
        end
    end

    for _, dep in ipairs(self.dependencies) do
        dep:install(handle_result)
    end
end

--- Install package and any defined dependencies
---@param on_done fun(success: boolean)?
function M:install(on_done)
    --- Handle install result
    ---@param success boolean
    local function handle_result(success)
        if success then
            self:mason_install(on_done)
        elseif on_done then
            on_done(success)
        end
    end

    self:install_dependencies(handle_result)
end

--- Create a new instance
---@param config MasonPackageConfig?
---@return MasonPackage?
function M.new(config)
    config = config or {}

    if not M.validate(config) then
        return
    end

    local pkg = { config = config }

    if pkg.config.dependencies then
        pkg.dependencies = {}

        for _, dep_cfg in ipairs(config.dependencies) do
            local dep = M.new(dep_cfg)
            if dep then
                table.insert(pkg.dependencies, dep)
            end
        end
    end

    return setmetatable(pkg, M)
end

return M

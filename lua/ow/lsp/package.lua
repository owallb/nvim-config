local utils = require("ow.utils")

---@class PostInstallStep
---@field cmd string[]

---@class MasonPackage
---@field dependencies? MasonPackage[]
---@field config MasonPackageConfig
local M = {}
M.__index = M

---@class MasonPackageConfig
---@field [1]? string
---@field name? string
---@field version? string
---@field dependencies? string[]|MasonPackageConfig[]
---@field post_install? PostInstallStep[]
M.config = {}

--- Validate MasonPackageConfig
---@param config string|MasonPackageConfig
---@return boolean
function M.validate(config)
    local ok, resp = pcall(vim.validate, { config = { config, { "table" } } })
    if ok then
        ok, resp = pcall(vim.validate, {
            name = { config.name or config[1], { "string" }, true },
            version = { config.version, { "string" }, true },
            dependencies = {
                config.dependencies,
                function(f)
                    if not f then
                        return true
                    end

                    for _, dep in ipairs(f) do
                        local t = type(dep)
                        if
                            (t ~= "string" and t ~= "table")
                            or (type(dep) == "table" and not M.validate(dep))
                        then
                            return false
                        end
                    end

                    return true
                end,
                "list of string|MasonPackageConfig",
            },
            post_install = {
                config.post_install,
                function(field)
                    if not field then
                        return true
                    end

                    if not utils.is_list(field) then
                        return false
                    end

                    for _, step in ipairs(field) do
                        local o, r = pcall(vim.validate, { step = { step, { "table" } } })
                        if o then
                            o, r = pcall(vim.validate, {
                                cmd = {
                                    step.cmd,
                                    function(f)
                                        return utils.is_list(f, "string")
                                    end,
                                    "list of strings or nil",
                                },
                            })
                        end

                        if not o then
                            utils.err(("Invalid config for post_install step: %s"):format(r), "LSP")
                            return false
                        end

                        return true
                    end

                    return true
                end,
                "list of steps",
            },
        })
    end

    if not ok then
        utils.err(
            ("Invalid config for %s:\n%s"):format(config.name or config[1] or config, resp),
            "LSP"
        )
        return false
    end

    return true
end

--- Run post installation steps
---@param pkg Package
function M:post_install(pkg)
    ---@param step PostInstallStep
    ---@param msg string
    local function log_err(step, msg)
        local cmd = table.concat(step.cmd, " ")

        utils.err(
            ("Post installation step for %s:\n`%s`\nfailed with:\n%s"):format(
                self.config.name,
                cmd,
                msg
            ),
            "LSP"
        )
    end

    if self.config.post_install then
        for _, step in ipairs(self.config.post_install) do
            utils.info("running post install step", "LSP")
            local cwd = pkg:get_install_path()
            local args = step.cmd
            local prog = table.remove(args, 1)

            if prog:find("[/\\]") then
                prog = vim.fn.resolve(("%s/%s"):format(cwd, prog))
            end

            if not utils.is_executable(prog) then
                log_err(step, "command not executable")
                return
            end

            local job = require("plenary.job"):new({
                command = prog,
                args = args,
                cwd = pkg:get_install_path(),
                enabled_recording = true,
                on_exit = vim.schedule_wrap(function(job, code, signal)
                    if code ~= 0 or signal ~= 0 then
                        log_err(step, table.concat(job:stderr_result(), "\n"))
                        return
                    end
                    utils.info("post install step done", "LSP")
                end),
            })
            job:start()
        end
    end
end

--- Handle installation
---@param pkg Package
---@param old_version? string
---@param new_version? string
---@param on_done? fun(success: boolean)
function M:handle_install(pkg, old_version, new_version, on_done)
    local version_str = ""
    if old_version and new_version then
        version_str = (" %s -> %s"):format(old_version, new_version)
    elseif new_version then
        version_str = " " .. new_version
    end

    utils.info(("Installing %s%s"):format(self.config.name, version_str), "LSP")
    local handle = pkg:install({ version = new_version })
    local err
    handle:on(
        "stderr",
        vim.schedule_wrap(function(msg)
            err = (err or "") .. msg
        end)
    )

    handle:once(
        "closed",
        vim.schedule_wrap(function()
            local is_installed = pkg:is_installed()

            if is_installed then
                utils.info(("Successfully installed %s"):format(self.config.name), "LSP")
                self:post_install(pkg)
            else
                if err then
                    err = ":\n" .. err
                else
                    err = ""
                end

                utils.err(("Failed to install %s%s"):format(self.config.name, err), "LSP")
            end

            if on_done then
                on_done(is_installed)
            end
        end)
    )
end

--- Perform installation
---@param on_done fun(success: boolean)?
function M:install(on_done)
    local registry = require("mason-registry")
    local success, result = pcall(registry.get_package, self.config.name)

    if not success then
        utils.err(("Failed to get package %s:\n%s"):format(self.config.name, result), "LSP")

        if on_done then
            on_done(false)
        end

        return
    end

    local pkg = result

    if not pkg:is_installed() then
        self:handle_install(pkg, nil, self.config.version, on_done)
    elseif self.config.version then
        pkg:get_installed_version(function(ok, version_or_err)
            if not ok then
                utils.err(
                    ("Failed to check currently installed version for %s:\n%s"):format(
                        self.config.name,
                        version_or_err
                    ),
                    "LSP"
                )
            elseif self.config.version ~= version_or_err then
                self:handle_install(pkg, version_or_err, self.config.version, on_done)
                return
            end

            if on_done then
                on_done(ok)
            end
        end)
    else
        pkg:check_new_version(function(update_available, res)
            local ok = type(res) == "table" or res == "Package is not outdated."

            if not ok then
                utils.err(
                    ("Failed to check for update for %s:\n%s"):format(self.config.name, res),
                    "LSP"
                )
            elseif update_available then
                self:handle_install(pkg, res.current_version, res.latest_version, on_done)
                return
            end

            if on_done then
                on_done(ok)
            end
        end)

        return
    end
end

--- Install package dependencies
---@param on_done fun(success: boolean)?
function M:install_dependencies(on_done)
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
        dep:install_with_dependencies(handle_result)
    end
end

--- Install package and any defined dependencies
---@param on_done fun(success: boolean)?
function M:install_with_dependencies(on_done)
    --- Handle install result
    ---@param success boolean
    local function handle_result(success)
        if success then
            self:install(on_done)
        elseif on_done then
            on_done(success)
        end
    end

    require("mason-registry").refresh(function()
        if self.dependencies and #self.dependencies ~= 0 then
            self:install_dependencies(handle_result)
        else
            self:install(on_done)
        end
    end)
end

--- Create a new instance
---@param config MasonPackageConfig|string
---@return MasonPackage|nil
function M.new(config)
    if type(config) == "string" then
        config = { config }
    end

    if not M.validate(config) then
        return
    end

    config.name = config.name or config[1]

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

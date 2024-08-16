local utils = require("utils")

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
                            utils.err(("Invalid config for post_install step: %s"):format(r))
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
        utils.err(("Invalid config for %s:\n%s"):format(config.name or config[1] or config, resp))
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
        local cmd = table.concat(step.cmd, " ")

        utils.err(
            ("Post installation step for %s:\n`%s`\nfailed with:\n%s"):format(
                self.config.name,
                cmd,
                msg
            ),
            "lsp.package:run_post_install"
        )
    end

    if self.config.post_install then
        for _, step in ipairs(self.config.post_install) do
            utils.info("running post install step")
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
                    utils.info("post install step done")
                end),
            })
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
        utils.err(pkg)

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
        end)
    )
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

    require("mason-registry").refresh(function()
        if self.dependencies and #self.dependencies ~= 0 then
            self:install_dependencies(handle_result)
        else
            self:mason_install(on_done)
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

local module_name = "lsp.package"
local utils = require("utils")

---@class PostInstallStep
---@field command string
---@field args string[]

---@class MasonPackageConfig
---@field name string?
---@field version string?
---@field dependencies MasonPackageConfig[]?
---@field post_install PostInstallStep[]?
local M = {}
M.__index = M

--- Run post installation steps
---@param pkg Package
function M:run_post_install(pkg)
    if self.post_install then
        for _, step in ipairs(self.post_install) do
            local job = require("plenary.job"):new({
                command = step.command,
                args = step.args,
                cwd = pkg:get_install_path(),
                enabled_recording = true,
                on_exit = function (job, code, signal)
                    if code ~= 0 or signal ~= 0 then
                        local cmd = step.command
                        if step.args then
                            cmd = cmd .. " " .. table.concat(step.args, " ")
                        end

                        utils.err(
                            ("Post installation step for %s:\n`%s`\nfailed with:\n%s"):format(
                                self.name,
                                cmd,
                                table.concat(job:stderr_result(), "\n")
                            ),
                            module_name
                        )
                    end
                end,
            })
            job:start()
        end
    end
end

--- Perform installation
---@param on_done fun(success: boolean)?
function M:mason_install(on_done)
    local registry = require("mason-registry")
    local ok, pkg = pcall(registry.get_package, self.name)
    if not ok then
        utils.err("Could not locate package " .. self.name, module_name)

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

    utils.info(("Installing %s"):format(self.name), module_name)
    local handle = pkg:install({ version = self.version, })

    local err
    handle:on("stderr", vim.schedule_wrap(function (msg)
        err = (err or "") .. msg
    end))

    handle:once("closed", vim.schedule_wrap(function ()
        local is_installed = pkg:is_installed()

        if is_installed then
            self:run_post_install(pkg)
            utils.info(("Successfully installed %s"):format(self.name), module_name)
        else
            if err then
                err = ":\n" .. err
            else
                err = ""
            end

            utils.err(
                ("Failed to install %s%s"):format(self.name, err),
                module_name
            )
        end

        if on_done then
            on_done(is_installed)
        end
    end))
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
---@param config MasonPackageConfig
---@return MasonPackageConfig
function M:new(config)
    config = config or {}

    if config.dependencies then
        for i, dep in ipairs(config.dependencies) do
            config.dependencies[i] = M:new(dep)
        end
    end

    setmetatable(config, self)
    return config
end

return M

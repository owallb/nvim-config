local M = {}

M.os_name = vim.uv.os_uname().sysname

--- Check that an executable is available
--- @param exe string Array to look for
--- @return boolean
function M.is_installed(exe)
    return vim.fn.executable(exe) == 1
end

--- Check that at least one executable is available
--- @param exes table Array of exes
--- @return boolean
function M.any_installed(exes)
    for _, e in ipairs(exes) do
        if M.is_installed(e) then
            return true
        end
    end

    return false
end

--- Asserts that an executable is available
--- Raises error if missing.
--- @param exe string Array to look for
function M.assert_installed(exe)
    if not M.is_installed(exe) then
        M.notify("Missing executable '" .. exe .. "'.")
    end
end

--- Asserts that at least one executable is available
--- Raises error if missing.
--- @param exes table Array of exes
function M.assert_any_installed(exes)
    if not M.any_installed(exes) then
        error("At least one of the following is required:\n" ..
            table.concat(exes, ", "))
    end
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function M.python3_module_is_installed(mod)
    if not M.is_installed("python3") then
        return false
    end

    local resp = vim.system({ "python3", "-c", "import " .. mod, }):wait()
    return resp.code == 0
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function M.assert_python3_module_installed(mod)
    if not M.python3_module_is_installed(mod) then
        error("Python3 module " .. mod .. " not installed")
    end
end

--- Send a notification
---@param msg string Message to send
---@param title string Title of notification
---@param level integer Log level
function M.notify(msg, title, level)
    if title and not pcall(require, "notify") then
        msg = "[" .. title .. "] " .. msg
    end
    vim.notify(msg, level, { title = title, })
end

--- Send a debug notification
---@param msg string Message to send
---@param title string Title of notification
function M.debug(msg, title)
    M.notify(msg, title, vim.log.levels.DEBUG)
end

--- Send an info notification
---@param msg string Message to send
---@param title string Title of notification
function M.info(msg, title)
    M.notify(msg, title, vim.log.levels.INFO)
end

--- Send a warning notification
---@param msg string Message to send
---@param title string Title of notification
function M.warn(msg, title)
    M.notify(msg, title, vim.log.levels.WARN)
end

--- Send an error notification
---@param msg string Message to send
---@param title string Title of notification
function M.err(msg, title)
    M.notify(msg, title, vim.log.levels.ERROR)
end

--- Attempts to load a module and logs errors on failure.
---@param module string The module to attempt to load.
---@param err_title string The error message title.
---@param on_success fun(module: unknown)? Will be called if module was loaded.
---@return unknown? module The loaded module if successful, otherwise nil.
function M.try_require(module, err_title, on_success)
    local has_module, resp = pcall(require, module)

    if has_module then
        if on_success then
            on_success(resp)
        end

        return resp
    end

    M.err(("Failed to load module %s"):format(module), err_title)
    M.err(resp, err_title)
end

--- Update table t1 with values in t2.
---@param table table<any, any> The table to update
---@param values table<any, any> The table with new values
function M.update_table(table, values)
    for k, v in pairs(values) do
        if type(v) == "table" and type(table[k] or false) == "table" then
            M.update_table(table[k], values[k])
        else
            table[k] = v
        end
    end
end

return M

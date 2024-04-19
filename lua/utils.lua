local M = {}

M.os_name = vim.uv.os_uname().sysname

--- Get the module path of a file
---@param file string
---@return string?
local function get_module_path(file)
    for _, rtp in ipairs(vim.api.nvim_list_runtime_paths()) do
        if file:sub(1, #rtp) == rtp then
            file = file:sub(#rtp + 2)

            if file:sub(1, 4) == "lua/" then
                file = file:sub(5)
            end

            return file:match("(.*)%.lua$"):gsub("[/\\]", ".")
        end
    end
end

--- Send a notification
---@param msg string Message to send
---@param title string? Title of notification
---@param level integer Log level
local function notify(msg, title, level)
    if not title then
        local info = debug.getinfo(3)
        local file = info.source
            and (info.source:sub(1, 1) == "@" and info.source:sub(2) or info.source)
            or nil
        local module = file and (get_module_path(file) or file) or nil
        title = module and module .. (info.name and info.name ~= "" and ":" .. info.name or "")
            or nil
    end
    if title and not pcall(require, "notify") then
        msg = "[" .. title .. "] " .. msg
    end
    vim.notify(msg, level, { title = title })
end

--- Check that an executable is available
--- @param exe string Array to look for
--- @return boolean
function M.is_executable(exe)
    return vim.fn.executable(exe) == 1
end

--- Check that at least one executable is available
--- @param exes table Array of exes
--- @return boolean
function M.any_installed(exes)
    for _, e in ipairs(exes) do
        if M.is_executable(e) then
            return true
        end
    end

    return false
end

--- Asserts that an executable is available
--- Raises error if missing.
--- @param exe string Array to look for
function M.assert_installed(exe)
    assert(M.is_executable(exe), "Missing executable '" .. exe .. "'.")
end

--- Asserts that at least one executable is available
--- Raises error if missing.
--- @param exes table Array of exes
function M.assert_any_installed(exes)
    assert(
        M.any_installed(exes),
        "At least one of the following is required:\n" .. table.concat(exes, ", ")
    )
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function M.python3_module_is_installed(mod)
    if not M.is_executable("python3") then
        return false
    end

    local resp = vim.system({ "python3", "-c", "import " .. mod }):wait()
    return resp.code == 0
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function M.assert_python3_module_installed(mod)
    if not M.python3_module_is_installed(mod) then
        error("Python3 module " .. mod .. " not installed")
    end
end

--- Send a debug notification
---@param msg string Message to send
---@param title string? Title of notification
function M.debug(msg, title)
    notify(msg, title, vim.log.levels.DEBUG)
end

--- Send an info notification
---@param msg string Message to send
---@param title string? Title of notification
function M.info(msg, title)
    notify(msg, title, vim.log.levels.INFO)
end

--- Send a warning notification
---@param msg string Message to send
---@param title string? Title of notification
function M.warn(msg, title)
    notify(msg, title, vim.log.levels.WARN)
end

--- Send an error notification
---@param msg string Message to send
---@param title string? Title of notification
function M.err(msg, title)
    notify(msg, title, vim.log.levels.ERROR)
end

--- Attempts to load a module and logs errors on failure.
---@param module string The module to attempt to load.
---@return any module The loaded module if successful, otherwise nil.
function M.try_require(module)
    local has_module, resp = pcall(require, module)

    if has_module then
        return resp
    end

    M.err(("Failed to load module %s:\n%s"):format(module, resp))
end

--- Check if `val` is a list of type `t` (if given)
---@param val any
---@param t type?
---@return boolean
function M.is_list(val, t)
    if type(val) ~= "table" then
        return false
    end

    for k, v in pairs(val) do
        if type(k) ~= "number" then
            return false
        end

        if t and type(v) ~= t then
            return false
        end
    end

    return true
end

--- Check if `val` is a list of type `t` (if given), or nil
---@param val any?
---@param t type?
---@return boolean
function M.is_list_or_nil(val, t)
    if val == nil then
        return true
    else
        return M.is_list(val, t)
    end
end

--- Creates a debounced function that delays execution of `fn` until after `delay` milliseconds have
--- elapsed since the last time it was invoked.
---@param fn fun(...) Function to be debounced
---@param delay number Debounce delay in milliseconds
---@return fun(...) function Debounced function
function M.debounce(fn, delay)
    ---@type uv_timer_t?
    local timer = nil

    return function(...)
        local args = vim.F.pack_len(...)
        if timer then
            timer:stop()
            timer = nil
        end

        timer = vim.defer_fn(function()
            timer = nil
            fn(vim.F.unpack_len(args))
        end, delay)
    end
end

--- Creates a debounced function that delays execution of `fn` until after `delay` milliseconds have
--- elapsed since the last time it was invoked with the same unique identifier.
---@param fn fun(...) Function to be debounced
---@param delay number Debounce delay in milliseconds
---@return fun(id: any, ...) function Debounced function, where `id` is a unique identifier
function M.debounce_with_id(fn, delay)
    local map = {}

    return function(id, ...)
        local args = vim.F.pack_len(...)
        if map[id] then
            map[id]:stop()
            map[id] = nil
        end

        map[id] = vim.defer_fn(function()
            map[id] = nil
            fn(vim.F.unpack_len(args))
        end, delay)
    end
end

return M

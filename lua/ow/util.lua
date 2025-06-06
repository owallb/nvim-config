local M = {}

M.os_name = vim.uv.os_uname().sysname

--- Get the module path of a file
---@param file string
---@return string|nil
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
---@param title? string Title of notification
---@param level integer Log level
local function notify(msg, title, level)
    if not title then
        local info = debug.getinfo(3)
        local file = info.source
                and (info.source:sub(1, 1) == "@" and info.source:sub(2) or info.source)
            or nil
        local module = file and (get_module_path(file) or file) or nil
        title = module
                and module .. (info.name and info.name ~= "" and ":" .. info.name or "")
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
        "At least one of the following is required:\n"
            .. table.concat(exes, ", ")
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

--- Checks if it is possible to require a module
---@param module string
---@return boolean
function M.has_module(module)
    local has_module, _ = pcall(require, module)
    return has_module
end

---@alias OutputStream
---| '"stdout"'
---| '"stderr"'
---| '"in_place"'

---@class FormatOptions
---@field cmd string[] Command to run. The following keywords get replaces by the specified values:
---                    * %file%         - path to the current file
---                    * %filename%     - name of the current file
---                    * %row_start%    - first row of selection
---                    * %row_end%      - last row of selection
---                    * %col_start%    - first column position of selection
---                    * %col_end%      - last column position of selection
---                    * %byte_start%   - byte count of first cell in selection
---                    * %byte_end%     - byte count of last cell in selection
---@field output OutputStream What stream to use as the result. May be one of `stdout`, `stderr` or `in_place`.
---@field auto_indent? boolean Perform auto indent on formatted range
---@field only_selection? boolean Only send the selected lines to `stdin`
---@field ignore_ret? boolean Ignore non-zero return codes
---@field ignore_stderr? boolean Ignore stderr output when not using stderr for output
---@field env? table<string, string> Map of environment variables

--- Format buffer
---@param opts FormatOptions
function M.format(opts)
    opts = {
        cmd = opts.cmd,
        output = opts.output,
        auto_indent = opts.auto_indent or false,
        only_selection = opts.only_selection or false,
        ignore_ret = opts.ignore_ret,
        ignore_stderr = opts.ignore_stderr,
        env = opts.env,
    }

    if
        opts.output ~= "stdout"
        and opts.output ~= "stderr"
        and opts.output ~= "in_place"
    then
        M.err(
            "`output` must be set to either `stdout`, `stderr` or `in_place`."
        )
        return
    end

    local file = vim.fn.expand("%")
    local filename = vim.fn.expand("%:t")

    local mode = vim.fn.mode()
    local is_visual = mode == "v" or mode == "V" or mode == ""

    local row_start, row_end, col_start, col_end, byte_start, byte_end
    if is_visual then
        row_start, col_start = unpack(vim.fn.getpos("v"), 2, 3)
        row_end, col_end = unpack(vim.fn.getpos("."), 2, 3)

        if row_start > row_end then
            row_start, row_end, col_start, col_end =
                row_end, row_start, col_end, col_start
        end

        if mode == "V" then
            col_start = 1
            col_end = #vim.fn.getline(row_end)
        end

        byte_start = vim.fn.line2byte(row_start) + col_start - 1
        byte_end = vim.fn.line2byte(row_end) + col_end - 1
    end

    local input
    if opts.only_selection then
        input = vim.api.nvim_buf_get_lines(0, row_start - 1, row_end, false)
    else
        input = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    end

    local tmp
    if opts.output == "in_place" then
        tmp = os.tmpname()
        vim.fn.writefile(input, tmp, "s")
        file = tmp
    end

    for i, arg in ipairs(opts.cmd) do
        arg = arg:gsub("%%file%%", file)
        arg = arg:gsub("%%filename%%", filename)
        if is_visual then
            arg = arg:gsub("%%row_start%%", row_start)
            arg = arg:gsub("%%row_end%%", row_end)
            arg = arg:gsub("%%col_start%%", col_start)
            arg = arg:gsub("%%col_end%%", col_end)
            arg = arg:gsub("%%byte_start%%", byte_start)
            arg = arg:gsub("%%byte_end%%", byte_end)
        end
        opts.cmd[i] = arg
    end

    local stdout, stderr, err
    local resp = vim.system(opts.cmd, {
        stdin = input,
        stdout = opts.output == "stdout" and function(e, data)
            if data then
                stdout = stdout and stdout .. data or data
            end

            if e then
                err = err and err .. e or e
            end
        end,
        stderr = not opts.ignore_stderr and function(e, data)
            if e then
                err = err and err .. e or e
            end

            if data then
                stderr = stderr and stderr .. data or data
            end
        end,
        env = opts.env,
    }):wait()

    local tmp_out
    if tmp then
        tmp_out = table.concat(vim.fn.readfile(tmp), "\n")
        os.remove(tmp)
    end

    if err then
        M.err("Error during formatting:\n%s" .. err)
        return
    end

    if
        not opts.ignore_ret and resp.code ~= 0
        or (opts.output ~= "stderr" and stderr)
    then
        local msg = ""
        if stderr then
            msg = ":\n" .. stderr
        end

        M.err(("Failed to format (%d)%s"):format(resp.code, msg))
        return
    end

    local output
    if opts.output == "stdout" then
        output = stdout
    elseif opts.output == "stderr" then
        output = stderr
    elseif opts.output == "in_place" then
        output = tmp_out
    end

    output = output or ""
    output = output:gsub("\n$", "")
    local output_lines = vim.fn.split(output, "\n", true)

    if opts.only_selection then
        vim.api.nvim_buf_set_lines(
            0,
            row_start - 1,
            row_end,
            false,
            output_lines
        )
    else
        vim.api.nvim_buf_set_lines(0, 0, -1, false, output_lines)
    end

    if opts.auto_indent then
        if is_visual then
            vim.api.nvim_command(
                ("%d,%dnormal! =="):format(row_start, row_start + #output_lines)
            )
        else
            vim.api.nvim_command("normal! gg=G")
        end
    end
end

--- Check if `val` is a list of type `t` (if given)
---@param val any
---@param kt type
---@param vt type
---@return boolean
function M.is_map(val, kt, vt)
    if type(val) ~= "table" then
        return false
    end

    for k, v in pairs(val) do
        if type(k) ~= kt then
            return false
        end

        if type(v) ~= vt then
            return false
        end
    end

    return true
end

--- Check if `val` is a list of type `t` (if given)
---@param val any
---@param t? type
---@return boolean
function M.is_list(val, t)
    if not vim.islist(val) then
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
---@param val? any
---@param t? type
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

function M.get_hl_source(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    while hl.link do
        hl = vim.api.nvim_get_hl(0, { name = hl.link })
    end

    return hl
end

return M

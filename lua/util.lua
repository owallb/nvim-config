local log = require("log")

local Util = {}

Util.os_name = vim.uv.os_uname().sysname

--- Check that an executable is available
--- @param exe string Array to look for
--- @return boolean
function Util.is_executable(exe)
    return vim.fn.executable(exe) == 1
end

--- Check that at least one executable is available
--- @param exes table Array of exes
--- @return boolean
function Util.any_installed(exes)
    for _, e in ipairs(exes) do
        if Util.is_executable(e) then
            return true
        end
    end

    return false
end

--- Asserts that an executable is available
--- Raises error if missing.
--- @param exe string Array to look for
function Util.assert_installed(exe)
    assert(Util.is_executable(exe), "Missing executable '" .. exe .. "'.")
end

--- Asserts that at least one executable is available
--- Raises error if missing.
--- @param exes table Array of exes
function Util.assert_any_installed(exes)
    assert(
        Util.any_installed(exes),
        "At least one of the following is required:\n"
            .. table.concat(exes, ", ")
    )
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function Util.python3_module_is_installed(mod)
    if not Util.is_executable("python3") then
        return false
    end

    local resp = vim.system({ "python3", "-c", "import " .. mod }):wait()
    return resp.code == 0
end

--- Asserts that a python module is installed
---@param mod string The python module to check
function Util.assert_python3_module_installed(mod)
    if not Util.python3_module_is_installed(mod) then
        error("Python3 module " .. mod .. " not installed")
    end
end

--- Attempts to load a module and logs errors on failure.
---@param module string The module to attempt to load.
---@return any module The loaded module if successful, otherwise nil.
function Util.try_require(module)
    local has_module, resp = pcall(require, module)

    if has_module then
        return resp
    end

    log.error("Failed to load module %s:\n%s", module, resp)
end

--- Checks if it is possible to require a module
---@param module string
---@return boolean
function Util.has_module(module)
    local has_module, _ = pcall(require, module)
    return has_module
end

---@alias OutputStream
---| '"stdout"'
---| '"stderr"'
---| '"in_place"'

---@class ow.FormatOptions
---@field buf integer Buffer to apply formatting to
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
---@field auto_indent boolean Perform auto indent on formatted range
---@field only_selection boolean Only send the selected lines to `stdin`
---@field ignore_ret boolean Ignore non-zero return codes
---@field ignore_stderr boolean Ignore stderr output when not using stderr for output
---@field env table<string, string> Map of environment variables
local FormatOptions = {}
FormatOptions.__index = FormatOptions

function FormatOptions.from_opts(opts)
    return setmetatable({
        buf = opts.buf or vim.api.nvim_get_current_buf(),
        cmd = opts.cmd,
        output = opts.output,
        auto_indent = opts.auto_indent or false,
        only_selection = opts.only_selection or false,
        ignore_ret = opts.ignore_ret,
        ignore_stderr = opts.ignore_stderr,
        env = opts.env,
    }, FormatOptions)
end

--- Format buffer
---@param opts table
function Util.format(opts)
    opts = FormatOptions.from_opts(opts)

    if
        opts.output ~= "stdout"
        and opts.output ~= "stderr"
        and opts.output ~= "in_place"
    then
        log.error(
            "`output` must be set to either `stdout`, `stderr` or `in_place`."
        )
        return
    end

    local file = vim.api.nvim_buf_get_name(opts.buf)
    local filename = vim.fn.fnamemodify(file, ":t")

    local mode = vim.fn.mode()
    local is_visual = mode == "v" or mode == "V" or mode == ""

    -- All 1-indexed, inclusive
    local row_start, row_end
    local col_start, col_end
    if is_visual then
        row_start, col_start = unpack(vim.fn.getpos("v"), 2, 3)
        row_end, col_end = unpack(vim.fn.getpos("."), 2, 3)

        if
            row_start > row_end
            or (row_start == row_end and col_start > col_end)
        then
            row_start, row_end, col_start, col_end =
                row_end, row_start, col_end, col_start
        end

        if mode == "V" then
            col_start = 1
            col_end = #vim.api.nvim_buf_get_lines(
                opts.buf,
                row_end - 1,
                row_end,
                false
            )[1]
        end
    else
        row_start = 1
        col_start = 1
        row_end = vim.api.nvim_buf_line_count(opts.buf)
        col_end = #vim.api.nvim_buf_get_lines(
            opts.buf,
            row_end - 1,
            row_end,
            false
        )[1]
    end

    local function get_byte_offset(buf, row, col)
        local lines = vim.api.nvim_buf_get_text(buf, 0, 0, row - 1, col - 1, {})
        return #table.concat(lines, "\n")
    end

    local byte_start = get_byte_offset(opts.buf, row_start, col_start)
    local byte_end = get_byte_offset(opts.buf, row_end, col_end) + 1

    local input
    if is_visual and opts.only_selection then
        input = vim.api.nvim_buf_get_text(
            opts.buf,
            row_start - 1,
            col_start - 1,
            row_end - 1,
            col_end,
            {}
        )
    else
        input = vim.api.nvim_buf_get_lines(opts.buf, 0, -1, false)
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
        log.error("Error during formatting:\n%s", err)
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

        log.error("Failed to format (%d)%s", resp.code, msg)
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
    output = output:gsub("%s+$", "")

    local old_lines = input
    local new_lines =
        vim.split(output:gsub("\r\n", "\n"), "\n", { plain = true })

    local diff = vim.diff(
        table.concat(old_lines, "\n"),
        table.concat(new_lines, "\n"),
        { result_type = "indices", algorithm = "histogram" }
    )

    if not diff or #diff == 0 then
        return
    end

    ---@type lsp.TextEdit[]
    local text_edits = {}
    local line_offset = (is_visual and opts.only_selection) and (row_start - 1)
        or 0

    ---@diagnostic disable-next-line: param-type-mismatch
    for i, hunk in ipairs(diff) do
        local old_start, old_count, new_start, new_count = unpack(hunk)

        local lines = {}
        for j = new_start, new_start + new_count - 1 do
            table.insert(lines, new_lines[j])
        end

        local is_last_hunk = i == #diff
        local is_at_eof = (line_offset + old_start - 1 + old_count)
            >= vim.api.nvim_buf_line_count(opts.buf)
        local needs_newline = new_count > 0 and not (is_last_hunk and is_at_eof)

        table.insert(text_edits, {
            range = {
                start = {
                    line = line_offset + old_start - 1,
                    character = 0,
                },
                ["end"] = {
                    line = line_offset + old_start - 1 + old_count,
                    character = 0,
                },
            },
            newText = table.concat(lines, "\n")
                .. (needs_newline and "\n" or ""),
        })
    end

    local view = vim.fn.winsaveview()

    vim.lsp.util.apply_text_edits(text_edits, opts.buf, vim.o.encoding)

    if opts.auto_indent then
        vim.api.nvim_cmd({
            cmd = "normal",
            args = { "==" },
            bang = true,
            range = {
                row_start,
                math.min(row_end, vim.api.nvim_buf_line_count(opts.buf)),
            },
        }, { output = false })
    end

    vim.fn.winrestview(view)
end

--- Check if `val` is a list of type `t` (if given)
---@param val any
---@param kt type
---@param vt type
---@return boolean
function Util.is_map(val, kt, vt)
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
function Util.is_list(val, t)
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
function Util.is_list_or_nil(val, t)
    if val == nil then
        return true
    else
        return Util.is_list(val, t)
    end
end

--- Creates a debounced function that delays execution of `fn` until after `delay` milliseconds have
--- elapsed since the last time it was invoked.
---@param fn fun(...) Function to be debounced
---@param delay number Debounce delay in milliseconds
---@return fun(...) function Debounced function
function Util.debounce(fn, delay)
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
function Util.debounce_with_id(fn, delay)
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

function Util.get_hl_source(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    while hl.link do
        hl = vim.api.nvim_get_hl(0, { name = hl.link })
    end

    return hl
end

return Util

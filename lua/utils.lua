--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

M = {}

M.os_name = vim.loop.os_uname().sysname

function M.has_value(tab, val)
    for _, value in ipairs(tab) do if value == val then return true end end

    return false
end

---@param cmd table: Array of executable + args
function M.exec(cmd)
    local out = vim.fn.system(cmd)
    local rc = vim.v.shell_error

    return { out = out, rc = rc }
end

function M.get_color(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

function M.get_hl(name)
    local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
    if not ok then return end
    for _, key in pairs({ 'foreground', 'background', 'special' }) do
        if hl[key] then hl[key] = string.format('#%06x', hl[key]) end
    end
    return hl
end

--- Check that an executable is available
--- @param exe string: Array to look for
--- @return boolean
function M.is_available(exe)
    return vim.fn.executable(exe) == 1
end

--- Check that at least one executable is available
--- @param exes table: Array of exes
--- @return boolean
function M.any_available(exes)
    for _, e in ipairs(exes) do
        if M.is_available(e) then
            return true
        end
    end

    return false
end

--- Asserts that an executable is available
--- Raises error if missing.
--- @param exe string: Array to look for
function M.assert_available(exe)
    if not M.is_available(exe) then
        error("Missing executable '" .. exe .. "'.")
    end
end

--- Asserts that at least one executable is available
--- Raises error if missing.
--- @param exes table: Array of exes
function M.assert_any_available(exes)
    if not M.any_available(exes) then
        error('At least one of the following is required:\n' .. table.concat(exes, ', '))
    end
end

return M

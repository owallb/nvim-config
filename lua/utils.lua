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

local M = {}

M.os_name = vim.loop.os_uname().sysname

--- Check that an executable is available
--- @param exe string: Array to look for
--- @return boolean
function M.is_installed(exe)
    return vim.fn.executable(exe) == 1
end

--- Check that at least one executable is available
--- @param exes table: Array of exes
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
--- @param exe string: Array to look for
function M.assert_installed(exe)
    if not M.is_installed(exe) then
        M.notify("Missing executable '" .. exe .. "'.")
    end
end

--- Asserts that at least one executable is available
--- Raises error if missing.
--- @param exes table: Array of exes
function M.assert_any_installed(exes)
    if not M.any_installed(exes) then
        error("At least one of the following is required:\n" .. table.concat(exes, ", "))
    end
end

--- Asserts that a python module is installed
---@param mod string: The python module to check
function M.python3_module_installed(mod)
    local resp = vim.system({ "python3", "-m", "pip", "show", mod, }):wait()
    if not resp.code == 0 then
        error("Python3 module " .. mod .. " not installed:\n" .. resp.stdout .. "\n" .. resp.stderr)
    end
end

function M.notify(msg, title, level)
    if title and not pcall(require, "notify") then
        msg = "[" .. title .. "] " .. msg
    end
    vim.notify(msg, level, { title = title, })
end

function M.debug(msg, title)
    M.notify(msg, title, vim.log.levels.DEBUG)
end

function M.info(msg, title)
    M.notify(msg, title, vim.log.levels.INFO)
end

function M.warn(msg, title)
    M.notify(msg, title, vim.log.levels.WARN)
end

function M.err(msg, title)
    M.notify(msg, title, vim.log.levels.ERROR)
end

return M

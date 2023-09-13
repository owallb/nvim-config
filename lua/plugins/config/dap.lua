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

-- https://github.com/mfussenegger/nvim-dap

vim.fn.execute("nnoremap <silent> <F5> :lua require'dap'.continue()<CR>")
vim.fn.execute("nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>")
vim.fn.execute("nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>")
vim.fn.execute("nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>")

local utils = require("utils")

local M = {}

local env_ok = false
local dap = nil

local function check_env()
    utils.assert_installed("python3")
    utils.assert_python3_module_installed("debugpy")
    env_ok = true
end

local function start(config)
    if not env_ok then
        check_env()
    end
    if not dap then
        dap = require("dap")
        dap.adapters.python = {
            type = "executable",
            command = "python",
            args = { "-m", "debugpy.adapter", },
            cwd = vim.fn.getcwd(),
        }
    end
    dap.run(config)
    -- List of events described at https://microsoft.github.io/debug-adapter-protocol/specification#Events
    -- Also see :h dap-extensions
    dap.listeners.after["event_initialized"]["nvim-dap.lua"] = function ()
        dap.set_exception_breakpoints({ "userUnhandled", })
    end
end

function M.launch(args)
    assert(type(args) == "table", "Args not specified or of wrong type")
    local config = {
        name = "Launch file",
        type = "python",
        request = "launch",
        program = "${file}",
        -- python = 'python';
        -- program = vim.fn.getcwd() .. '/.venv/bin/pytest';
        console = "integratedTerminal",
        args = args,
    }
    start(config)
end

function M.pytest(args)
    assert(type(args) == "table", "Args not specified or of wrong type")
    local config = {
        name = "pytest " .. table.concat(args, " "),
        type = "python",
        request = "launch",

        -- pythonPath = vim.fn.getcwd() .. '/.venv/bin/python',
        module = "pytest",
        -- python = 'python';
        -- program = vim.fn.getcwd() .. '/.venv/bin/pytest';
        args = args,
        console = "integratedTerminal",
        -- program = "${file}";
    }
    start(config)
end

return M

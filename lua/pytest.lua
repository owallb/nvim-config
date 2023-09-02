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

local utils = require("utils")

M = {}

local env_ok = false
local dap = nil

local function check_env()
    local debugpy = utils.exec("python -m debugpy --version")
    assert(debugpy.rc == 0, "Python module debugpy is required")
    local pytest = utils.exec("python -m pytest --version")
    assert(pytest.rc == 0, "Python module pytest is required")
    env_ok = true
end

local function load_dap()
    local ok, dap = pcall(require, "dap")
    assert(ok, "nvim-dap is required")
    return dap
end

function M.run(args)
    assert(type(args) == "table", "Args not specified or of wrong type")
    if not env_ok then
        check_env()
    end
    if not dap then
        dap = load_dap()
        dap.adapters.python = {
            type = "executable",
            command = "python",
            args = { "-m", "debugpy.adapter", },
            cwd = vim.fn.getcwd(),
        }
    end
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
    -- session = dap.launch(adapter, config)
    dap.run(config)
    -- List of events described at https://microsoft.github.io/debug-adapter-protocol/specification#Events
    -- Also see :h dap-extensions
    dap.listeners.after["event_initialized"]["pytest.lua"] = function (session, body)
        dap.set_exception_breakpoints({ "userUnhandled", })
    end
end

return M

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

local M = {}

M.env_ok = false

function M.check_env()
    local utils = require("utils")

    utils.assert_installed("python3")
    utils.assert_python3_module_installed("debugpy")
    M.env_ok = true
end

function M.start(config)
    local dap = require("dap")

    if not M.env_ok then
        M:check_env()
    end

    dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter", },
        cwd = vim.fn.getcwd(),
    }
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
    M.start(config)
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
    M.start(config)
end

function M.setup()
    local dap = require("dap")

    vim.keymap.set("n", "<F5>", dap.continue)
    vim.keymap.set("n", "<F10>", dap.step_over)
    vim.keymap.set("n", "<F11>", dap.step_into)
    vim.keymap.set("n", "<F12>", dap.step_out)

    --[[
        TODO: Add this after loading dap for integrating catppuccin:
        local sign = vim.fn.sign_define

        sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = ""})
        sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = ""})
        sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = ""})
    --]]
end

return M

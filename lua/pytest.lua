-- TODO: clean this up.
-- For other readers: I don't currently use this, and is probably broken.
-- This was started as a work in progress a long time ago.

local utils = require("utils")

local M = {}

local env_ok = false
local dap = nil

local function check_env()
    utils.assert_installed("python3")
    utils.assert_python3_module_installed("debugpy")
    utils.assert_python3_module_installed("pytest")
    env_ok = true
end

function M.run(args)
    assert(type(args) == "table", "Args not specified or of wrong type")
    if not env_ok then
        check_env()
    end
    if not dap then
        dap = require("dap")
        dap.adapters.python = {
            type = "executable",
            command = "python3",
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
    dap.listeners.after["event_initialized"]["pytest.lua"] = function (_, _)
        dap.set_exception_breakpoints({ "userUnhandled", })
    end
end

return M

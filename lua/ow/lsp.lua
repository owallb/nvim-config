local utils = require("ow.utils")

local CONFIG_DIR = vim.fn.stdpath("config") .. "/lua/ow/lsp/config"

---@class Server
local Server = require("ow.lsp.server")

---@class LSP
---@field diagnostic_signs vim.diagnostic.Opts.Signs
local M = {}

M.diagnostic_signs = {
    text = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
    },
}

---@type table<string, Server>
local servers = {}

function M.get_servers()
    return servers
end

local function get_module_name(filepath)
    return filepath:match("([^/\\]+)%.lua$")
end

local function get_server_config(name)
    local module = "ow.lsp.config." .. name
    package.loaded[module] = nil
    return utils.try_require("ow.lsp.config." .. name)
end

local reload_server_config = utils.debounce_with_id(function(name, events)
    utils.info(("Reloading server with new config"):format(name), name)
    ---@type Server|nil
    local server = servers[name]

    if server and server.config.enable then
        server:deinit()
        servers[name] = nil
    end

    if events.rename then
        local _, _, err_name =
            vim.uv.fs_stat(("%s/%s.lua"):format(CONFIG_DIR, name))
        if err_name == "ENOENT" then
            return
        end
    end

    local config = get_server_config(name)
    if not config then
        return
    end

    server = Server.new(name, config)
    if not server or not server.config.enable then
        return
    end

    local on_done = function(success)
        if success then
            utils.info(("%s reloaded"):format(name))
        end
    end

    if #server:get_ft_buffers() ~= 0 then
        server:setup(on_done)
    else
        server:init(on_done)
    end

    servers[name] = server
end, 1000)

local function process_change(error, filename, events)
    if error then
        utils.err(
            ("Error on change for %s:\n%s"):format(filename, error),
            "ow.lsp.on_config_change"
        )
        return
    end

    local name = get_module_name(filename)
    if not name or name == "init" then
        return
    end

    reload_server_config(name, name, events)
end

local function load_configs()
    local handle = vim.uv.fs_scandir(CONFIG_DIR)
    while handle do
        local filepath = vim.uv.fs_scandir_next(handle)

        if not filepath then
            break
        end

        local name = get_module_name(filepath)

        if name == "init" then
            goto continue
        end

        local config = get_server_config(name)

        if not config then
            goto continue
        end

        local server = Server.new(name, config)
        if server then
            servers[name] = server
        end

        ::continue::
    end

    vim.uv.fs_event_start(
        vim.uv.new_fs_event(),
        CONFIG_DIR,
        {},
        vim.schedule_wrap(process_change)
    )
end

--- Setup diagnostics UI
local function setup_diagnostics()
    vim.diagnostic.config({
        underline = true,
        signs = M.diagnostic_signs,
        virtual_text = false,
        float = {
            show_header = false,
            source = true,
            border = "rounded",
            focusable = false,
            format = function(diagnostic)
                return string.format("%s", diagnostic.message)
            end,
            width = 80,
        },
        update_in_insert = false,
        severity_sort = true,
        jump = {
            float = true,
            wrap = false,
        },
    })
end

function M.setup()
    load_configs()
    setup_diagnostics()

    for _, server in pairs(servers) do
        if server.config.enable then
            server:init()
        end
    end
end

return M

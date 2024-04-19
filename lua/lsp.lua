local utils = require("utils")

local CONFIG_DIR = vim.fn.stdpath("config") .. "/lua/lsp/config"

---@class Server
local Server = require("lsp.server")

local M = {}

---@type table<string, Server>
local servers = {}

function M.get_servers()
    return servers
end

local function get_module_name(filepath)
    return filepath:match("([^/\\]+)%.lua$")
end

local function get_server_config(name)
    local module = "lsp.config." .. name
    package.loaded[module] = nil
    return utils.try_require("lsp.config." .. name)
end

local reload_server_config = utils.debounce_with_id(function(name, events)
    utils.debug(("Reloading server %s"):format(name))
    ---@type Server?
    local server = servers[name]

    if server and server.config.enable then
        server:unload()
        servers[name] = nil
    end

    if events.rename then
        local _, _, err_name = vim.uv.fs_stat(("%s/%s.lua"):format(CONFIG_DIR, name))
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

    if #server:get_ft_buffers() ~= 0 then
        server:setup()
    else
        server:register()
    end

    servers[name] = server
end, 100)

local function process_change(error, filename, events)
    utils.debug(("Got event: %s, %s, %s"):format(filename, vim.inspect(events), error))
    if error then
        utils.err(("Error on change for %s:\n%s"):format(filename, error), "lsp.on_config_change")
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
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#customizing-how-diagnostics-are-displayed
    vim.diagnostic.config({
        underline = true,
        signs = true,
        virtual_text = {
            prefix = "",
            format = function(diagnostic)
                return diagnostic.message
            end,
        },
        float = {
            show_header = false,
            source = true,
            border = "single",
            focusable = false,
            format = function(diagnostic)
                return string.format("%s", diagnostic.message)
            end,
        },
        update_in_insert = false,
        severity_sort = false,
    })
    local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

function M.setup()
    load_configs()
    setup_diagnostics()

    for _, server in pairs(servers) do
        if server.config.enable then
            server:register()
        end
    end
end

return M

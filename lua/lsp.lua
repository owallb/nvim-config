local module_name = "lsp"
local utils = require("utils")

---@class ServerConfig
local Server = require("lsp.server")

local M = {}

---@type table<string, ServerConfig>
local servers = {
    bashls = {},
    clangd = {},
    cmake = {},
    diagnosticls = {},
    gopls = {},
    groovyls = {},
    intelephense = {},
    pylsp = {},
    lemminx = {},
    lua_ls = {},
    rust_analyzer = {},
    zls = {},
}

for name, _ in pairs(servers) do
    utils.try_require(
        "lsp.config." .. name,
        module_name,
        ---@param cfg ServerConfig
        function (cfg)
            cfg.name = name
            servers[name] = Server:new(cfg)
        end
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
            format = function (diagnostic)
                return diagnostic.message
            end,
        },
        float = {
            show_header = false,
            source = true,
            border = "single",
            focusable = false,
            format = function (diagnostic)
                return string.format("%s", diagnostic.message)
            end,
        },
        update_in_insert = false,
        severity_sort = false,
    })
    local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " ", }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl, })
    end
end

function M.setup()
    setup_diagnostics()

    for _, server in pairs(servers) do
        if server.enable then
            server:register()
        end
    end
end

return M

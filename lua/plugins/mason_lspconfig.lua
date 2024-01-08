-- https://github.com/williamboman/mason-lspconfig.nvim

local function setup()
    require("mason-lspconfig").setup({
        -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
        -- This setting has no relation with the `automatic_installation` setting.
        ---@type string[]
        ensure_installed = require("lsp").language_servers(),
    })
end

return setup

---@type ServerConfig
return {
    enable = true,
    mason = { "mesonlsp" },
    lspconfig = {
        settings = {
            others = {
                disableInlayHints = true,
            },
        },
    },
}

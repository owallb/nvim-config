local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = lsp.on_attach,
    settings = {
        others = {
            disableInlayHints = true,
        },
    },
}

local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = lsp.on_attach,
    init_options = {
        completion = {
            disableSnippets = true,
        },
        diagnostics = {
            enable = true,
        },
    },
}

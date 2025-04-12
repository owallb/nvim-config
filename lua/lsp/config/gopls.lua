local utils = require("utils")

---@type ServerConfig
return {
    enable = true,
    mason = { "gopls", dependencies = { "golines" } },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = { "golines", "-m", "80", "--shorten-comments" },
                    output = "stdout",
                })
                vim.lsp.buf.format({ async = true })
            end,
        },
    },
    lspconfig = {
        filetypes = {
            "go",
            "gomod",
            "gowork",
            "gotmpl",
        },
        cmd = { "gopls" },
        single_file_support = true,
        settings = {
            gopls = {
                staticcheck = true,
                semanticTokens = true,
            },
        },
    },
}

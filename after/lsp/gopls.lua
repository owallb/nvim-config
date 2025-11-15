local lsp = require("lsp")
local util = require("util")

---@type vim.lsp.Config
return {
    settings = {
        gopls = {
            staticcheck = true,
            semanticTokens = true,
        },
    },
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        vim.keymap.set("n", "<leader>lf", function()
            util.format({
                buf = bufnr,
                cmd = {
                    "golines",
                    "-m",
                    "80",
                    "--shorten-comments",
                },
                output = "stdout",
            })
            vim.lsp.buf.format({ async = true })
        end, { buffer = bufnr })
    end,
}

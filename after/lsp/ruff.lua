local lsp = require("lsp")
local util = require("util")

---@type vim.lsp.Config
return {
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        vim.keymap.set("n", "<leader>lf", function()
            vim.lsp.buf.format()
            util.format({
                buf = bufnr,
                cmd = {
                    "ruff",
                    "check",
                    "--stdin-filename=%file%",
                    "--select=I",
                    "--fix",
                    "--quiet",
                    "-",
                },
                output = "stdout",
            })
        end, { buffer = bufnr })
    end,
}

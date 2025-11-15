local lsp = require("lsp")
local util = require("util")

---@type vim.lsp.Config
return {
    filetypes = {
        "sh",
        "bash",
        "zsh",
    },
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        vim.keymap.set("n", "<leader>lf", function()
            util.format({
                buf = bufnr,
                cmd = { "shfmt", "-s", "-i", "4", "-" },
                output = "stdout",
            })
        end, { buffer = bufnr })
    end,
}

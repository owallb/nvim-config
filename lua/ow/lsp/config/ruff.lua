local utils = require("ow.utils")

---@type ServerConfig
return {
    mason = "ruff",
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                vim.lsp.buf.format()
                utils.format({
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
            end,
        },
    },
}

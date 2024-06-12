local utils = require("utils")

return {
    enable = true,
    dependencies = {
        "npm",
    },
    mason = {
        name = "bash-language-server",
        dependencies = {
            { name = "shellcheck", },
            { name = "shfmt", },
        },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = { "shfmt", "-s", "-i", "4", "-" },
                    stdin = true,
                    stdout = true,
                })
            end,
        },
    },
    lspconfig = {
        filetypes = {
            "sh",
            "bash",
            "zsh",
        },
        cmd = { "bash-language-server", "start", },
        single_file_support = true,
    },
}

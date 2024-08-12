local utils = require("utils")

return {
    enable = true,
    dependencies = {
        "npm",
    },
    mason = {
        "bash-language-server",
        dependencies = {
            { "shellcheck" },
            { "shfmt" },
        },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = { "shfmt", "-s", "-i", "4", "-" },
                    output = "stdout",
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
        cmd = { "bash-language-server", "start" },
        single_file_support = true,
    },
}

local utils = require("utils")

---@type ServerConfig
return {
    enable = true,
    mason = { "gopls", dependencies = { "golines", "golangci-lint" } },
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
    linters = {
        {
            cmd = {
                "golangci-lint",
                "run",
                "--output.json.path=stdout",
                "--show-stats=false",
                "%file%",
            },
            stdin = true,
            stdout = true,
            json = {
                diagnostics_root = "Issues",
                source = "FromLinter",
                message = "Text",
                lnum = "Pos.Line",
                col = "Pos.Column",
                callback = function(diag)
                    if not diag.severity or diag.severity == "" then
                        diag.severity = vim.diagnostic.severity.WARN
                    end
                    utils.debug(vim.inspect(diag))
                end,
            },
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
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = false,
            },
        },
    },
}

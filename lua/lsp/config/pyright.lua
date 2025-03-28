local utils = require("utils")

---@type ServerConfig
return {
    enable = true,
    mason = { "pyright", dependencies = { "ruff" } },
    linters = {
        {
            cmd = {
                "ruff",
                "check",
                "--output-format=json",
                "--line-length=80",
                "--preview",
                "--select=YTT,ANN,ASYNC,B,A,COM,C4,DTZ,T10,FIX,FA,ISC,PIE,PYI",
                "--extend-select=PT,RET,SIM,TC,I,C90,DOC,D,F,PL,UP,RUF",
                "--ignore=D203,D301,D101",
                "-q",
                "-",
            },
            stdin = true,
            stdout = true,
            json = {
                lnum = "location.row",
                end_lnum = "end_location.row",
                col = "location.column",
                end_col = "end_location.column",
                code = "code",
                message = "message",
                callback = function(diag)
                    local map = {
                        YTT = vim.diagnostic.severity.HINT,
                        ANN = vim.diagnostic.severity.HINT,
                        ASYNC = vim.diagnostic.severity.HINT,
                        B = vim.diagnostic.severity.HINT,
                        A = vim.diagnostic.severity.HINT,
                        COM = vim.diagnostic.severity.HINT,
                        C = vim.diagnostic.severity.HINT,
                        DTZ = vim.diagnostic.severity.HINT,
                        T = vim.diagnostic.severity.HINT,
                        FIX = vim.diagnostic.severity.HINT,
                        FA = vim.diagnostic.severity.HINT,
                        ISC = vim.diagnostic.severity.HINT,
                        PIE = vim.diagnostic.severity.HINT,
                        PYI = vim.diagnostic.severity.HINT,
                        PT = vim.diagnostic.severity.HINT,
                        RET = vim.diagnostic.severity.HINT,
                        SIM = vim.diagnostic.severity.HINT,
                        TC = vim.diagnostic.severity.HINT,
                        I = vim.diagnostic.severity.HINT,
                        E = vim.diagnostic.severity.ERROR,
                        W = vim.diagnostic.severity.WARN,
                        DOC = vim.diagnostic.severity.HINT,
                        D = vim.diagnostic.severity.INFO,
                        F = vim.diagnostic.severity.HINT,
                        PLC = vim.diagnostic.severity.HINT,
                        PLE = vim.diagnostic.severity.ERROR,
                        PLR = vim.diagnostic.severity.HINT,
                        PLW = vim.diagnostic.severity.WARN,
                        UP = vim.diagnostic.severity.HINT,
                        RUF = vim.diagnostic.severity.HINT,
                    }
                    if diag.code then
                        diag.severity = map[diag.code:match("^(%u+)")]
                    end
                end,
            },
            source = "ruff",
        },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "ruff",
                        "format",
                        "--line-length=80",
                        "--stdin-filename=%filename%",
                        "--quiet",
                        "-",
                    },
                    output = "stdout",
                })
                utils.format({
                    cmd = {
                        "ruff",
                        "check",
                        "--select=I",
                        "--fix",
                        "--quiet",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
        {
            mode = "x",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "ruff",
                        "format",
                        "--line-length=80",
                        "--stdin-filename=%filename%",
                        "--quiet",
                        "--range=%row_start%:%col_start%-%row_end%:%col_end%",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
    },
    lspconfig = {
        filetypes = { "python" },
        cmd = { "pyright-langserver", "--stdio" },
        single_file_support = true,
        settings = {
            python = {
                analysis = {
                    disable = true,
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "strict",
                },
            },
        },
    },
}

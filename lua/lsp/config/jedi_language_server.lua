local utils = require("utils")

local ERROR = vim.diagnostic.severity.ERROR
local WARN = vim.diagnostic.severity.WARN
local INFO = vim.diagnostic.severity.INFO
local HINT = vim.diagnostic.severity.HINT

local SEVERITY_MAP = {
    YTT = WARN,
    ANN = WARN,
    ASYNC = WARN,
    B = WARN,
    A = WARN,
    COM = WARN,
    C = WARN,
    DTZ = WARN,
    T = WARN,
    FIX = WARN,
    FA = WARN,
    ISC = WARN,
    PIE = WARN,
    PYI = WARN,
    PT = WARN,
    RET = WARN,
    SIM = WARN,
    TC = WARN,
    I = WARN,
    E = ERROR,
    W = WARN,
    DOC = WARN,
    D = INFO,
    F = WARN,
    PLC = WARN,
    PLE = ERROR,
    PLR = WARN,
    PLW = WARN,
    UP = WARN,
    RUF = WARN,
}

---@type ServerConfig
return {
    enable = true,
    mason = { "jedi-language-server", dependencies = { "ruff" } },
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
                "--ignore=D203,D301,D101,D202,TC006,COM812",
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
                    if diag.severity or not diag.code then
                        return
                    end
                    diag.severity = SEVERITY_MAP[diag.code:match("^(%u+)")]
                end,
            },
            source = "ruff",
            tags = {
                deprecated = {
                    "PYI057",
                    "PT020",
                    "UP005",
                    "UP019",
                    "UP021",
                    "UP023",
                    "UP026",
                    "UP035",
                },
                unnecessary = {
                    "ARG001",
                    "ARG002",
                    "ARG003",
                    "ARG004",
                    "ARG005",
                    "F401",
                    "F504",
                    "F522",
                    "F811",
                    "F841",
                    "F842",
                    "RUF029",
                    "RUF059",
                    "RUF100",
                },
            },
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
        filetypes = {
            "python",
        },
        cmd = { "jedi-language-server" },
        single_file_support = true,
        init_options = {
            completion = {
                disableSnippets = true,
            },
            diagnostics = {
                enable = true,
            },
        },
    },
}

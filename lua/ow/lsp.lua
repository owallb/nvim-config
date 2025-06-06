---@type fun(name: string, cfg: vim.lsp.Config)
vim.lsp.config = vim.lsp.config

local keymap = require("ow.lsp.keymap")
local linter = require("ow.lsp.linter")
local log = require("ow.log")
local util = require("ow.util")

local M = {}

M.diagnostic_signs = {
    text = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
    },
}

---@param fn? fun(client: vim.lsp.Client, bufnr: integer)
---@return fun(client: vim.lsp.Client, bufnr: integer)
function M.with_defaults(fn)
    return function(client, bufnr)
        keymap.set_defaults(bufnr)

        -- For document highlight
        vim.cmd.highlight({ "link LspReferenceRead Visual", bang = true })
        vim.cmd.highlight({ "link LspReferenceText Visual", bang = true })
        vim.cmd.highlight({ "link LspReferenceWrite Visual", bang = true })

        client.settings = M.with_file(
            string.format(".%s.json", client.name),
            client.settings
        ) or client.settings

        if fn then
            fn(client, bufnr)
        end
    end
end

--- Load a JSON file and return a parsed table merged with settings
---@param path string
---@param settings? table
---@return table?
function M.with_file(path, settings)
    local file = io.open(path, "r")
    if not file then
        return
    end

    local json = file:read("*all")
    file:close()
    local ok, resp = pcall(
        vim.json.decode,
        json,
        { luanil = { object = true, array = true } }
    )
    if not ok then
        log.warning("Failed to parse json file %s: %s", path, resp)
        return
    end

    return vim.tbl_deep_extend("force", settings or {}, resp)
end

function M.setup()
    vim.diagnostic.config({
        underline = true,
        signs = M.diagnostic_signs,
        virtual_text = false,
        float = {
            show_header = false,
            source = true,
            border = "rounded",
            focusable = false,
            format = function(diagnostic)
                return string.format("%s", diagnostic.message)
            end,
            width = 80,
        },
        update_in_insert = false,
        severity_sort = true,
        jump = {
            float = true,
            wrap = false,
        },
    })

    vim.lsp.enable({
        "bashls",
        "clangd",
        "cmake",
        "gopls",
        "intelephense",
        -- "jedi_language_server",
        "lemminx",
        "lua_ls",
        "mesonlsp",
        -- "phpactor",
        -- "pyrefly",
        "pyright",
        "ruff",
        "rust_analyzer",
        "zls",
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_nvim_lsp = util.try_require("cmp_nvim_lsp")
    if cmp_nvim_lsp then
        capabilities = vim.tbl_deep_extend(
            "force",
            capabilities,
            cmp_nvim_lsp.default_capabilities()
        )
    end

    vim.lsp.config("*", {
        on_attach = M.with_defaults(),
        capabilities = capabilities,
    })

    vim.lsp.config("bashls", {
        filetypes = {
            "sh",
            "bash",
            "zsh",
        },
        on_attach = M.with_defaults(function(_, bufnr)
            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "<leader>lf",
                    rhs = function()
                        util.format({
                            cmd = { "shfmt", "-s", "-i", "4", "-" },
                            output = "stdout",
                        })
                    end,
                },
            })
        end),
    })

    vim.lsp.config("clangd", {
        filetypes = {
            "c",
            "cpp",
        },
        cmd = {
            "clangd",
            "--clang-tidy",
            "--enable-config",
            -- Fix for errors in files outside of project
            -- https://clangd.llvm.org/faq#how-do-i-fix-errors-i-get-when-opening-headers-outside-of-my-project-directory
            "--compile-commands-dir=build",
        },
        single_file_support = true,
        on_attach = M.with_defaults(function(_, bufnr)
            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "gs",
                    rhs = vim.cmd.ClangdSwitchSourceHeader,
                },
            })
        end),
    })

    vim.lsp.config("cmake", {
        init_options = {
            buildDirectory = "build",
        },
    })

    vim.lsp.config("gopls", {
        settings = {
            gopls = {
                staticcheck = true,
                semanticTokens = true,
            },
        },
        on_attach = M.with_defaults(function(_, bufnr)
            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "<leader>lf",
                    rhs = function()
                        util.format({
                            cmd = {
                                "golines",
                                "-m",
                                "80",
                                "--shorten-comments",
                            },
                            output = "stdout",
                        })
                        vim.lsp.buf.format({ async = true })
                    end,
                },
            })
        end),
    })

    vim.lsp.config("intelephense", {
        settings = {
            intelephense = {
                environment = {
                    phpVersion = "8.4",
                },
                format = {
                    enable = true,
                    braces = "psr12",
                },
            },
        },
        on_attach = M.with_defaults(function(_, bufnr)
            linter.add(bufnr, {
                cmd = {
                    "phpcs",
                    "--standard=PSR12",
                    "--report=emacs",
                    "-s",
                    "-q",
                    "-",
                },
                stdin = true,
                stdout = true,
                pattern = "^.+:(%d+):(%d+): (%w+) %- (.*) %((.*)%)$",
                groups = { "lnum", "col", "severity", "message", "source" },
                source = "phpcs",
                severity_map = {
                    error = vim.diagnostic.severity.ERROR,
                    warning = vim.diagnostic.severity.WARN,
                },
                zero_idx_col = true,
                zero_idx_lnum = true,
            })

            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "<leader>lf",
                    rhs = function()
                        vim.lsp.buf.format()
                        util.format({
                            cmd = {
                                "php-cs-fixer",
                                "fix",
                                "%file%",
                                "--quiet",
                            },
                            output = "in_place",
                            ignore_stderr = true,
                            env = { PHP_CS_FIXER_IGNORE_ENV = "1" },
                        })
                    end,
                },
            })
        end),
    })

    vim.lsp.config("jedi_language_server", {
        init_options = {
            completion = {
                disableSnippets = true,
            },
            diagnostics = {
                enable = true,
            },
        },
    })

    vim.lsp.config("lemminx", {
        init_options = {
            settings = {
                xml = {
                    format = {
                        enabled = true, -- is able to format document
                        splitAttributes = true, -- each attribute is formatted onto new line
                        joinCDATALines = false, -- normalize content inside CDATA
                        joinCommentLines = false, -- normalize content inside comments
                        formatComments = true, -- keep comment in relative position
                        joinContentLines = false, -- normalize content inside elements
                        spaceBeforeEmptyCloseLine = true, -- insert whitespace before self closing tag end bracket
                    },
                    validation = {
                        noGrammar = "ignore",
                        enabled = true,
                        schema = true,
                    },
                },
            },
        },
    })

    local lua_library_paths = {
        vim.env.VIMRUNTIME,
    }
    for _, plugin in ipairs(require("lazy").plugins()) do
        table.insert(lua_library_paths, plugin.dir)
    end

    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                completion = { showWord = "Disable" },
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                    },
                    pathStrict = true,
                },
                workspace = {
                    library = lua_library_paths,
                    checkThirdParty = false,
                },
                hint = {
                    enable = false,
                    arrayIndex = "Disable",
                    await = true,
                    paramName = "All",
                    paramType = true,
                    semicolon = "Disable",
                    setType = true,
                },
                telemetry = { enable = false },
            },
        },
        on_attach = M.with_defaults(function(_, bufnr)
            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "<leader>lf",
                    rhs = function()
                        util.format({
                            cmd = { "stylua", "-" },
                            output = "stdout",
                        })
                    end,
                },
                {
                    mode = "x",
                    lhs = "<leader>lf",
                    rhs = function()
                        util.format({
                            cmd = {
                                "stylua",
                                "-",
                                "--range-start",
                                "%byte_start%",
                                "--range-end",
                                "%byte_end%",
                            },
                            output = "stdout",
                        })
                    end,
                },
            })
        end),
    })

    vim.lsp.config("mesonlsp", {
        settings = {
            others = {
                disableInlayHints = true,
            },
        },
    })

    vim.lsp.config("pyright", {
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "strict",
                    stubPath = "stubs",
                },
            },
            pyright = {
                disableLanguageServices = false,
            },
        },
    })

    vim.lsp.config("ruff", {
        on_attach = M.with_defaults(function(_, bufnr)
            keymap.set(bufnr, {
                {
                    mode = "n",
                    lhs = "<leader>lf",
                    rhs = function()
                        vim.lsp.buf.format()
                        util.format({
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
            })
        end),
    })

    vim.lsp.config("rust_analyzer", {
        settings = {
            ["rust-analyzer"] = {
                inlayHints = {
                    chainingHints = {
                        enable = false,
                    },
                    parameterHints = {
                        enable = false,
                    },
                    typeHints = {
                        enable = false,
                    },
                },
            },
        },
    })

    vim.lsp.config("zls", {
        settings = {
            zls = {
                warn_style = true,
                highlight_global_var_declarations = true,
                inlay_hints_show_variable_type_hints = false,
                inlay_hints_show_struct_literal_field_type = false,
                inlay_hints_show_parameter_name = false,
                inlay_hints_show_builtin = false,
            },
        },
    })

    vim.lsp.config("pyrefly", {})
end

return M

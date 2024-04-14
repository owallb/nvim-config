--- @type ServerConfig
return {
    enable = true,
    dependencies = {
        "python3",
    },
    py_module_deps = {
        "venv",
    },
    mason = {
        name = "python-lsp-server",
        post_install = {
            {
                command = "./venv/bin/pip",
                args = {
                    "install",
                    "python-lsp-black",
                    "python-lsp-isort",
                },
            },
            -- {
            --     command = "./venv/bin/pip",
            --     args = { "alsdkfjhaklsdfjhl", },
            -- },
        },
    },
    lspconfig = {
        filetypes = {
            "python",
        },
        cmd = { "pylsp", },
        single_file_support = true,
        settings = {
            pylsp = {
                configurationSources = { "flake8", },
                plugins = {
                    autopep8 = {
                        enabled = false,
                    },
                    black = {
                        enabled = true,
                        line_length = 100,
                    },
                    flake8 = {
                        enabled = true,
                        exclude = { ".venv", "build/", },
                        filename = { "*.py", },
                        -- B - flake8-bugbear https://github.com/PyCQA/flake8-bugbear
                        -- C - only one violation, C901. mccabe https://github.com/PyCQA/mccabe
                        -- D - flake8-docstrings (pydocstyle) http://www.pydocstyle.org/en/stable/error_codes.html
                        -- E - pycodestyle https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
                        -- F - flake8 https://flake8.pycqa.org/en/latest/user/error-codes.html
                        -- W - pycodestyle https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
                        select = {
                            "B", "B902", "B903", "B904", "C", "E", "E999", "E501", "F", "W",
                        },
                        ignore = {
                            "B950", "D201", "D203", "D205", "D301", "D400", "E133", "E203", "W503",
                        },
                        max_line_length = 100,
                        max_doc_length = 100,
                    },
                    isort = {
                        enabled = true,
                    },
                    mccabe = {
                        enabled = false,
                    },
                    pycodestyle = {
                        enabled = false,
                    },
                    pydocstyle = {
                        enabled = false,
                    },
                    pyflakes = {
                        enabled = false,
                    },
                    yapf = {
                        enabled = false,
                    },
                },
            },
        },
    },
}
return {
    enable = true,
    dependencies = {
        "python3",
    },
    py_module_deps = {
        "venv",
    },
    mason = {
        name = "cmake-language-server",
        -- version = "",
    },
    lspconfig = {
        filetypes = {
            "cmake",
        },
        cmd = { "cmake-language-server", },
        single_file_support = true,
        init_options = {
            buildDirectory = "build",
        },
    },
}

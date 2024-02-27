return {
    enabled = true,
    dependencies = {
        "python3",
    },
    py_module_deps = {
        "venv",
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

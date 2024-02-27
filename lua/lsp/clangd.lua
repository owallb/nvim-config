return {
    enable = true,
    mason = {
        name = "clangd",
        -- version = "",
    },
    lspconfig = {
        filetypes = {
            "c",
            "cpp",
            "objc",
            "objcpp",
            "cuda",
            "proto",
        },
        cmd = {
            "clangd",
            "--clang-tidy",
            "--enable-config",
        },
        single_file_support = true,
    },
}

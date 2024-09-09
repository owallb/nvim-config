---@type ServerConfig
return {
    enable = true,
    keymaps = {
        {
            mode = "n",
            lhs = "gs",
            rhs = vim.cmd.ClangdSwitchSourceHeader,
        },
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

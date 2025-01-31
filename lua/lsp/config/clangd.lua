---@type ServerConfig
return {
    enable = true,
    mason = { "clangd" },
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
    },
}

-- spec: https://github.com/zigtools/zls#configuration-options

return {
    enable = true,
    dependencies = {
        "zig",
    },
    -- mason = {
    --     name = "zls",
    --     -- version = "",
    -- },
    lspconfig = {
        filetypes = {
            "zig",
            "zir",
        },
        cmd = { "zls", },
        single_file_support = true,
        settings = {
            zls = {
                enable_autofix = false,
                enable_inlay_hints = false,
                enable_build_on_save = true,
                warn_style = true,
                highlight_global_var_declarations = true,
            },
        },
    },
}

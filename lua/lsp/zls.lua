return {
    enabled = true,
    dependencies = {
        "zig",
    },
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

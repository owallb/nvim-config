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
                enable_inlay_hints = false,
            },
        },
    },
}

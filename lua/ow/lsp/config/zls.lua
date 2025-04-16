-- spec: https://github.com/zigtools/zls#configuration-options

---@type ServerConfig
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
                warn_style = true,
                highlight_global_var_declarations = true,
                inlay_hints_show_variable_type_hints = false,
                inlay_hints_show_struct_literal_field_type = false,
                inlay_hints_show_parameter_name = false,
                inlay_hints_show_builtin = false,
            },
        },
    },
}

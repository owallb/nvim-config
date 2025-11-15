local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = lsp.on_attach,
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
}

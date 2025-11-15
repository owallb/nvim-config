local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        local handler_name = "textDocument/publishDiagnostics"
        local default_handler = client.handlers[handler_name]
        or vim.lsp.handlers[handler_name]
        client.handlers[handler_name] = function(err, result, context, config)
            if result and result.diagnostics then
                result.diagnostics = vim.tbl_filter(function(diagnostic)
                    return diagnostic.severity < vim.diagnostic.severity.HINT
                end, result.diagnostics)
            end

            default_handler(err, result, context, config)
        end
    end,
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
                extraArgs = {
                    "--",
                    "-Wclippy::pedantic",
                },
            },
            diagnostics = {
                styleLints = {
                    enable = true,
                },
            },
            imports = {
                prefix = "self",
            },
            inlayHints = {
                chainingHints = {
                    enable = false,
                },
                parameterHints = {
                    enable = false,
                },
                typeHints = {
                    enable = false,
                },
            },
            rustfmt = {
                extraArgs = { "+nightly" },
            },
        },
    },
}

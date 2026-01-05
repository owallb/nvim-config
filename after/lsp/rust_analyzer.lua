local lsp = require("lsp")

---@type vim.lsp.Config
return {
    on_attach = lsp.on_attach,
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

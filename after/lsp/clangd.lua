local Linter = require("linter")
local lsp = require("lsp")

---@type vim.lsp.Config
return {
    filetypes = {
        "c",
        "cpp",
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
    on_attach = function(client, bufnr)
        lsp.on_attach(client, bufnr)

        Linter.add(bufnr, {
            cmd = {
                "clang-tidy",
                "-p=build",
                "--quiet",
                "--checks=-*,"
                .. "clang-analyzer-*,"
                .. "-clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling,"
                .. "-clang-analyzer-security.insecureAPI.strcpy",
                "%file%",
            },
            events = { "BufWritePost" },
            clear_events = { "TextChanged", "TextChangedI" },
            stdin = false,
            stdout = true,
            pattern = "^.+:(%d+):(%d+): (%w+): (.*) %[(.*)%]$",
            groups = { "lnum", "col", "severity", "message", "code" },
            source = "clang-tidy",
            severity_map = {
                error = vim.diagnostic.severity.ERROR,
                warning = vim.diagnostic.severity.WARN,
                note = vim.diagnostic.severity.HINT,
            },
            zero_idx_col = true,
            zero_idx_lnum = true,
            ignore_stderr = true,
        })

        vim.keymap.set(
            "n",
            "gs",
            vim.cmd.LspClangdSwitchSourceHeader,
            { buffer = bufnr }
        )
    end,
}

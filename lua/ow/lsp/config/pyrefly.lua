local util = require("lspconfig.util")

---@type ServerConfig
return {
    enable = false,
    dependencies = { "pyrefly" },
    lspconfig = {
        cmd = { "pyrefly", "lsp" },
        filetypes = { "python" },
        root_dir = util.root_pattern(
            "pyrefly.toml",
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git"
        ),
    },
}

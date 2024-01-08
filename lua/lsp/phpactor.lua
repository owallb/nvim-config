-- spec: https://phpactor.readthedocs.io/en/master/reference/configuration.html

return {
    enabled = false,
    dependencies = {
        "php",
        "composer",
    },
    root_pattern = {
        "composer.json",
        "composer.lock",
        "vendor",
    },
    lspconfig = {
        filetypes = {
            "php",
        },
        cmd = { "phpactor", "language-server", },
        single_file_support = true,
        init_options = {
            -- using custom php-cs-fixer setup in diagnosticls,
            -- due to issue when opening file with CRLF
            ["language_server_php_cs_fixer.enabled"] = true,
            -- ["logging.enabled"] = true,
            -- ["logging.path"] = "/tmp/application.log",
            -- ["logging.level"] = "debug",
        },
    },
}

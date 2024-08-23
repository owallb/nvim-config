-- spec: https://github.com/eclipse/lemminx/blob/main/docs/Configuration.md

local utils = require("utils")

return {
    enable = true,
    mason = {
        name = "lemminx",
        dependencies = { "xmlformatter" },
    },
    keymaps = {
        {
            mode = "n",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "xmlformat",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
        {
            mode = "x",
            lhs = "<leader>lf",
            rhs = function()
                utils.format({
                    cmd = {
                        "xmlformat",
                        "-",
                    },
                    output = "stdout",
                })
            end,
        },
    },
    lspconfig = {
        filetypes = {
            "xml",
            "xsd",
            "xsl",
            "xslt",
            "svg",
        },
        cmd = { "lemminx", },
        single_file_support = true,
        init_options = {
            settings = {
                xml = {
                    format = {
                        enabled = false, -- is able to format document
                        splitAttributes = true, -- each attribute is formatted onto new line
                        joinCDATALines = false, -- normalize content inside CDATA
                        joinCommentLines = false, -- normalize content inside comments
                        formatComments = true, -- keep comment in relative position
                        joinContentLines = false, -- normalize content inside elements
                        spaceBeforeEmptyCloseLine = true, -- insert whitespace before self closing tag end bracket
                    },
                    validation = {
                        noGrammar = "ignore",
                        enabled = true,
                        schema = true,
                    }
                },
            },
        },
    },
}

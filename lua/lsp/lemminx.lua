-- spec: https://github.com/eclipse/lemminx/blob/main/docs/Configuration.md

return {
    enabled = true,
    mason = {
        name = "lemminx",
        -- version = "",
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
                        enabled = true, -- is able to format document
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

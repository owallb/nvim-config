--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-- spec: https://github.com/eclipse/lemminx/blob/main/docs/Configuration.md

return {
    enabled = true,
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

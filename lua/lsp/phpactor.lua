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

-- spec: https://phpactor.readthedocs.io/en/master/reference/configuration.html

return {
    enabled = false,
    dependencies = {
        "php",
        "composer",
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
            -- ["language_server_php_cs_fixer.enabled"] = false,
            -- ["logging.enabled"] = true,
            -- ["logging.path"] = "/tmp/application.log",
            -- ["logging.level"] = "debug",
        },
    },
}

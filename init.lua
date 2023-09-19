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

local module_name = "base"

local utils = require("utils")

local files = {
    "globals",
    "options",
    "autocommands",
    "mappings",
    "user_commands",
}

for _, file in ipairs(files) do
    local pkg = "core." .. file
    local ok, err = pcall(require, pkg)
    if not ok then
        utils.err("Error while loading package " .. pkg, module_name)
        utils.err(err, module_name)
        return
    end
end

if vim.g.vscode then
    -- VSCode extension
else
    local ok, err = pcall(require, "bootstrap")
    if not ok then
        utils.err("Error during bootstrap", module_name)
        utils.err(err:gsub("\t", "  "), module_name)
        return
    end

    ok, err = pcall(require, "plugins")
    if not ok then
        utils.err("Error while loading plugins", module_name)
        utils.err(err:gsub("\t", "  "), module_name)
        return
    end
end

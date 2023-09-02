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

local files = { "globals", "options", "autocommands", "mappings", }

for _, file in ipairs(files) do
    local pkg = "core." .. file
    local ok, err = pcall(require, pkg)
    if not ok then
        print("Error while loading package " .. pkg)
        print(err)
        return
    end
end

if vim.g.vscode then
    -- VSCode extension
else
    local ok, err = pcall(require, "bootstrap")
    if not ok then
        print("Error during bootstrap")
        print(err:gsub("\t", "  "))
        return
    end

    ok, err = pcall(require, "plugins")
    if not ok then
        print("Error while loading plugins")
        print(err:gsub("\t", "  "))
        return
    end
end

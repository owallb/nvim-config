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

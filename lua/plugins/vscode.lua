-- https://github.com/Mofiqul/vscode.nvim

local function setup()
    local vscode = require("vscode")

    vscode.setup({
        style = "dark",
        transparent = false,
        italic_comments = false,
        disable_nvimtree_bg = false,
    })

    vscode.load()
end

return setup

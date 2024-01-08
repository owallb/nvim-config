-- https://github.com/folke/tokyonight.nvim

local function setup()
    local tokyonight = require("tokyonight")

    tokyonight.setup({
        style = "night",
        styles = {
            comments = { italic = false, },
            keywords = { italic = false, },
        },
        lualine_bold = false,
    })

    tokyonight.load()
end

return setup

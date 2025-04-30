---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    -- enabled = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        local c = require("onedark.palette").dark
        local opts = {
            style = "dark",
            highlights = {
                NormalFloat = { bg = c.bg0 },
                FloatBorder = { bg = c.bg0 },
                TabLineSel = { fg = c.fg, bg = c.bg0 }
            },
        }
        require("onedark").setup(opts)
        -- Enable theme
        require("onedark").load()
    end,
}

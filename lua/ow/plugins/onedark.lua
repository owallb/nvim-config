---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        require("onedark").setup({ style = "darker" })

        local c = require("onedark.colors")
        local highlights = {
            NormalFloat = { bg = c.bg0 },
            FloatBorder = { bg = c.bg0 },
            TabLineSel = { fg = c.fg, bg = c.bg0 },
            EndOfBuffer = { fg = "NONE", bg = "NONE" },
            NvimTreeIndentMarker = { fg = c.bg3 },
        }
        require("onedark").set_options("highlights", highlights)

        require("onedark").colorscheme()
    end,
}

---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        local c = require("onedark.palette").darker
        local opts = {
            style = "darker",
            highlights = {
                NormalFloat = { bg = c.bg0 },
                FloatBorder = { bg = c.bg0 },
                TabLineSel = { fg = c.fg, bg = c.bg0 },
                EndOfBuffer = nil,
                NvimTreeIndentMarker = { fg = c.bg3 },
            },
        }
        require("onedark").setup(opts)
        require("onedark").load()
    end,
}

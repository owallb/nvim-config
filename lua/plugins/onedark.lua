---@type LazyPluginSpec
return {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        require("onedark").setup({ style = "darker" })

        local c = require("onedark.colors")
        local highlights = {
            ["@string.special.url"] = { fg = "NONE", fmt = "NONE" },
            Cursor = { fg = c.bg, bg = c.fg, fmt = "NONE" },
            FloatTitle = { fg = c.orange, bg = c.bg_d },
            NormalFloat = { bg = c.bg_d },
            FloatBorder = { bg = c.bg_d },
            TabLine = { fg = c.grey, bg = c.bg1 },
            TabLineSel = { fg = c.fg, bg = c.bg2 },
            TabLineFill = { bg = c.bg1 },
            EndOfBuffer = { fg = "NONE", bg = "NONE" },
            NvimTreeIndentMarker = { fg = c.bg3 },
            TelescopeNormal = { bg = c.bg_d },
            TelescopeTitle = { fg = c.orange, bg = c.bg_d },
            TelescopePromptBorder = { fg = c.grey, bg = c.bg_d },
            TelescopeResultsBorder = { fg = c.grey, bg = c.bg_d },
            TelescopePreviewBorder = { fg = c.grey, bg = c.bg_d },
            DiffAdd = { bg = "#1a2f22" },
            DiffChange = { bg = "#15304a" },
            DiffDelete = { bg = "#311c1e" },
        }
        require("onedark").set_options("highlights", highlights)
        require("onedark").load()
    end,
}

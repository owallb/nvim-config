-- https://github.com/NvChad/nvim-colorizer.lua

---@type LazyPluginSpec
return {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    opts = {
        user_default_options = {
            names = false,
            RGB = false,
            RRGGBB = true,
            RRGGBBAA = true,
            AARRGGBB = true,
            rgb_fn = true,
            hsl_fn = true,
            mode = "virtualtext",
        },
    },
}

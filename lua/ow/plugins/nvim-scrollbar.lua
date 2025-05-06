---@type LazyPluginSpec
return {
    "petertriho/nvim-scrollbar",
    config = true,
    opts = {
        handle = {
            blend = 0,
        },
        excluded_filetypes = {
            "NvimTree",
        },
        handlers = {
            cursor = false,
            search = true,
        }
    },
}

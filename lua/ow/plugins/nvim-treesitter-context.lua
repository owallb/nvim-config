---@type LazyPluginSpec
return {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
        mode = 'topline',
        max_lines = 3,
        multiline_threshold = 1,
        multiwindow = true,
    },
}

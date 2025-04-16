-- https://github.com/numToStr/Comment.nvim

---@type LazyPluginSpec
return {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {
        --ignore empty lines
        ignore = "^$",
    },
}

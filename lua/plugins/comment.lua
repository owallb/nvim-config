-- https://github.com/numToStr/Comment.nvim

---@type LazyPluginSpec
return {
    "numToStr/Comment.nvim",
    lazy = true,
    event = "VimEnter",
    opts = {
        --ignore empty lines
        ignore = "^$",
    },
}

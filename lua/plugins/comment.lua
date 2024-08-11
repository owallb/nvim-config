-- https://github.com/numToStr/Comment.nvim

---@type LazyPluginSpec
return {
    "numToStr/Comment.nvim",
    event = "VimEnter",
    opts = {
        --ignore empty lines
        ignore = "^$",
    },
}

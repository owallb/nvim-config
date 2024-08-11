-- https://github.com/simeji/winresizer

---@type LazyPluginSpec
return {
    "simeji/winresizer",
    keys = {
        { "<C-W>r", vim.cmd.WinResizerStartResize, mode = "n" },
    },
    init = function()
        vim.g.winresizer_vert_resize = "5"
        vim.g.winresizer_horiz_resize = "5"
        vim.g.winresizer_start_key = ""
    end,
}

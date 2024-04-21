-- https://github.com/sindrets/winshift.nvim

---@type LazyPluginSpec
return {
    "sindrets/winshift.nvim",
    lazy = true,
    keys = {
        { "<C-W>m", vim.cmd.WinShift, mode = "n" },
    },
}

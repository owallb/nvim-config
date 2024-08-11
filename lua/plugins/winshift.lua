-- https://github.com/sindrets/winshift.nvim

---@type LazyPluginSpec
return {
    "sindrets/winshift.nvim",
    keys = {
        { "<C-W>m", vim.cmd.WinShift, mode = "n" },
    },
}

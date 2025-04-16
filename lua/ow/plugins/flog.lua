-- https://github.com/rbong/vim-flog

---@type LazyPluginSpec
return {
    "rbong/vim-flog",
    ---@type LazyKeysSpec[]
    keys = {
        { "<leader>gl", vim.cmd.Flog, mode = "n" },
    },
}

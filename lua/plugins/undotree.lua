local function undo_tree_tab()
    vim.cmd.tabnew()
    vim.cmd.bprevious()
    vim.cmd.UndotreeToggle()
    vim.cmd.UndotreeFocus()
end

---@type LazyPluginSpec
return {
    "mbbill/undotree",
    keys = {
        { "<leader>uu", undo_tree_tab, mode = "n" },
    },
    init = function(_)
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_DiffCommand = "diff -u"
        vim.g.undotree_SplitWidth = 50
        vim.g.undotree_DiffpanelHeight = 20
    end,
}

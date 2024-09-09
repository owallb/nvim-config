local module_name = "core.user_commands"
local utils = require("utils")

vim.api.nvim_create_user_command("Update", function(_)
    local lazy = utils.try_require("lazy")
    if lazy then
        lazy.update()
    end

    local treesitter_install = utils.try_require("nvim-treesitter.install")
    if treesitter_install then
        treesitter_install.update({ with_sync = true })("all")
    end

    local mason_update_all = utils.try_require("mason-update-all")
    if mason_update_all then
        mason_update_all.update_all()
    end
end, {
    desc = "Update lazy plugins, treesitter parsers and mason language servers",
    force = false,
})

vim.api.nvim_create_user_command("Cmake", function(ctx)
    local args = ctx.fargs
    if vim.tbl_isempty(args) then
        args = { "--build", "build" }
    end

    local mp = vim.o.makeprg
    vim.o.makeprg = "cmake"
    local ok, res = pcall(vim.cmd.make, { args = args, bang = ctx.bang })
    vim.o.makeprg = mp

    if not ok then
        utils.err(res)
    end
end, {
    desc = "Like :make, but for CMake",
    force = false,
    nargs = "*",
})

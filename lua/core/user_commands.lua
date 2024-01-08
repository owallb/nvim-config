local module_name = "core.user_commands"
local utils = require("utils")

vim.api.nvim_create_user_command(
    "Update",
    function (_)
        utils.try_require(
            "lazy",
            module_name,
            function (lazy)
                lazy.update()
            end
        )

        utils.try_require(
            "nvim-treesitter.install",
            module_name,
            function (treesitter_install)
                treesitter_install.update({ with_sync = true, })("all")
            end
        )

        utils.try_require(
            "mason-update-all",
            module_name,
            function (mason_update_all)
                mason_update_all.update_all()
            end
        )
    end,
    {
        desc =
        "Update lazy plugins, treesitter parsers and mason language servers",
        force = false,
    }
)

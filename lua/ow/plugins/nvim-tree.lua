local function override_highlights()
    -- Git
    vim.cmd.highlight({
        "link NvimTreeGitDeletedIcon MoonflyTurquoise",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitDirtyIcon MoonflyTurquoise",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitIgnoredIcon Comment",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitMergeIcon MoonflyCrimson",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitNewIcon MoonflyOrchid",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitRenamedIcon MoonflyTurquoise",
        bang = true,
    })
    vim.cmd.highlight({
        "link NvimTreeGitStagedIcon MoonflyGreen",
        bang = true,
    })

    -- Bookmarks
    vim.cmd.highlight({
        "link NvimTreeBookmarkHL MoonflyYellowLineActive",
        bang = true,
    })

    -- Clipboard
    vim.cmd.highlight({
        "link NvimTreeCutHL MoonflyRedLineActive",
        bang = true,
    })

    -- Modified
    vim.cmd.highlight({
        "link NvimTreeModifiedIcon MoonflyTurquoise",
        bang = true,
    })
end

local function disable_highlights()
    -- File types
    vim.cmd.highlight({ "clear NvimTreeExecFile" })
    vim.cmd.highlight({
        "link NvimTreeExecFile NONE",
        bang = true,
    })
    vim.cmd.highlight({ "clear NvimTreeImageFile" })
    vim.cmd.highlight({
        "link NvimTreeImageFile NONE",
        bang = true,
    })
    vim.cmd.highlight({ "clear NvimTreeSpecialFile" })
    vim.cmd.highlight({
        "link NvimTreeSpecialFile NONE",
        bang = true,
    })
    vim.cmd.highlight({ "clear NvimTreeSymlink" })
    vim.cmd.highlight({
        "link NvimTreeSymlink NONE",
        bang = true,
    })
end

---@type LazyPluginSpec
return {
    "nvim-tree/nvim-tree.lua",
    event = "VimEnter",
    keys = {
        {
            "<leader>tt",
            function()
                require("nvim-tree.api").tree.toggle({
                    find_file = true,
                    focus = false,
                })
            end,
        },
        {
            "<leader>a",
            function()
                require("nvim-tree.api").tree.open()
            end,
        },
    },
    config = function()
        ---@class nvim_tree.api.decorator.UserDecorator
        local UserDecorator = require("nvim-tree.api").decorator.UserDecorator

        ---@class GitIgnoreDecorator: nvim_tree.api.decorator.UserDecorator
        local GitIgnoreDecorator = UserDecorator:extend()

        function GitIgnoreDecorator:new()
            self.enabled = true
            self.highlight_range = "name"
            self.icon_placement = "none"
            self.file_hl = "NvimTreeGitFileIgnoredHL"
            self.folder_hl = "NvimTreeGitFolderIgnoredHL"
        end

        ---@param node Node
        ---@return string? highlight_group
        function GitIgnoreDecorator:highlight_group(node)
            local status = node.git_status
            if not status then
                return
            end

            if status.file == "!!" then
                return self.file_hl
            elseif status.dir and status.dir.direct == "!!" then
                return self.folder_hl
            end
        end

        override_highlights()

        local signs = require("ow.lsp").diagnostic_signs
        require("nvim-tree").setup({
            on_attach = function(bufnr)
                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end

                local api = require("nvim-tree.api")
                api.config.mappings.default_on_attach(bufnr)

                vim.keymap.del("n", "D", { buffer = bufnr })
                vim.keymap.del("n", "bt", { buffer = bufnr })

                vim.keymap.set("n", "d", api.fs.trash, opts("Trash"))
                vim.keymap.set(
                    "n",
                    "bd",
                    api.marks.bulk.trash,
                    opts("Trash Bookmarked")
                )
                vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                vim.keymap.set(
                    "n",
                    "h",
                    api.node.navigate.parent_close,
                    opts("Close Directory")
                )
            end,
            hijack_cursor = true,
            hijack_netrw = false,
            view = {
                width = 40,
                preserve_window_proportions = true,
            },
            renderer = {
                full_name = true,
                root_folder_label = ":~",
                special_files = {},
                decorators = {
                    "Git",
                    GitIgnoreDecorator,
                    "Open",
                    "Modified",
                    "Bookmark",
                    "Diagnostics",
                    "Copied",
                    "Cut",
                },
                highlight_modified = "icon",
                highlight_bookmarks = "name",
                highlight_clipboard = "all",
                indent_markers = {
                    enable = true,
                },
                icons = {
                    git_placement = "right_align",
                    diagnostics_placement = "signcolumn",
                    bookmarks_placement = "after",
                    symlink_arrow = " -> ",
                    show = {
                        file = false,
                        folder = false,
                        folder_arrow = false,
                        bookmarks = false,
                    },
                    glyphs = {
                        modified = "*",
                        git = {
                            unstaged = "M",
                            staged = "M",
                            unmerged = "!",
                            renamed = "R",
                            untracked = "?",
                            deleted = "D",
                            ignored = " ",
                        },
                    },
                },
            },
            update_focused_file = {
                enable = true,
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = {
                    hint = signs.text[vim.diagnostic.severity.HINT],
                    info = signs.text[vim.diagnostic.severity.INFO],
                    warning = signs.text[vim.diagnostic.severity.WARN],
                    error = signs.text[vim.diagnostic.severity.ERROR],
                },
            },
            modified = {
                enable = true,
            },
            filters = {
                git_ignored = false,
                custom = { "^\\.git$" },
            },
            live_filter = {
                prefix = "Filter: ",
                always_show_folders = false,
            },
            filesystem_watchers = {
                enable = true,
            },
            actions = {
                use_system_clipboard = false,
                change_dir = {
                    enable = false,
                },
                expand_all = {
                    exclude = { ".venv", "build" },
                },
                open_file = {
                    window_picker = {
                        enable = false,
                    },
                },
            },
            notify = {
                threshold = vim.log.levels.WARN,
                absolute_path = false,
            },
            help = {
                sort_by = "desc",
            },
        })

        disable_highlights()

        require("nvim-tree.api").tree.toggle({
            find_file = true,
            focus = false,
        })
    end,
}

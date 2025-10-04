local util = require("util")

local function override_highlights()
    -- File Icon
    local hl = util.get_hl_source("NvimTreeFileIcon")
    vim.api.nvim_set_hl(0, "NvimTreeFileIcon", { fg = hl.fg, bg = nil })

    -- Symlink Icon
    hl = util.get_hl_source("NvimTreeSymlinkIcon")
    vim.api.nvim_set_hl(0, "NvimTreeSymlinkIcon", { fg = hl.fg, bg = nil })
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
    dependencies = {
        "tpope/vim-fugitive",
        "nvim-tree/nvim-web-devicons",
    },
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
            "ga",
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

        local signs = require("lsp").diagnostic_signs
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
                vim.keymap.set("n", "<C-l>", api.node.open.edit, opts("Open"))
                vim.keymap.set(
                    "n",
                    "<C-h>",
                    api.node.navigate.parent_close,
                    opts("Close Directory")
                )
            end,
            hijack_cursor = true,
            hijack_netrw = false,
            view = {
                width = 50,
                preserve_window_proportions = true,
            },
            renderer = {
                full_name = true,
                root_folder_label = function(path)
                    local label = vim.fn.fnamemodify(path, ":~")
                    local git_head = vim.fn.FugitiveHead()
                    if git_head ~= "" then
                        label = label .. ("  %s"):format(git_head)
                    end
                    return label
                end,
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
                    icons = {
                        corner = "│",
                        none = "│",
                    },
                },
                icons = {
                    git_placement = "after",
                    diagnostics_placement = "signcolumn",
                    bookmarks_placement = "after",
                    symlink_arrow = " -> ",
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = false,
                        bookmarks = false,
                    },
                    web_devicons = {
                        file = {
                            color = false,
                        },
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
            sync_root_with_cwd = true,
        })

        override_highlights()
        disable_highlights()

        vim.api.nvim_create_autocmd("QuitPre", {
            callback = function()
                local tree_wins = {}
                local floating_wins = {}
                local wins = vim.api.nvim_list_wins()
                for _, w in ipairs(wins) do
                    local bufname =
                        vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
                    if bufname:match("NvimTree_") ~= nil then
                        table.insert(tree_wins, w)
                    end
                    if vim.api.nvim_win_get_config(w).relative ~= "" then
                        table.insert(floating_wins, w)
                    end
                end
                if 1 == #wins - #floating_wins - #tree_wins then
                    -- Should quit, so we close all invalid windows.
                    for _, w in ipairs(tree_wins) do
                        vim.api.nvim_win_close(w, true)
                    end
                end
            end,
        })
    end,
}

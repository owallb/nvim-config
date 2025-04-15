local function toggle_neo_tree()
    require("neo-tree.command").execute({
        action = "show",
        position = "left",
        toggle = true,
        reveal = true,
    })
end

local function focus_neo_tree()
    require("neo-tree.command").execute({
        action = "focus",
        reveal = true,
    })
end

---@type LazyPluginSpec
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    lazy = false,
    keys = {
        {
            "<leader>tt",
            toggle_neo_tree,
        },
        {
            "<leader>a",
            focus_neo_tree,
        },
    },
    ---@type neotree.Config?
    opts = {
        sources = {
            "filesystem",
            "git_status",
        },
        close_if_last_window = true,
        default_component_configs = {
            diagnostics = {
                symbols = {
                    hint = "H",
                    info = "I",
                    warn = "W",
                    error = "E",
                },
            },
            indent = {
                with_markers = false,
            },
            ---@diagnostic disable-next-line: missing-fields
            icon = {
                provider = function(icon, _, _)
                    icon.text = ""
                end,
            },
            modified = {
                symbol = "[+] ",
                highlight = "NeoTreeModified",
            },
            name = {
                use_git_status_colors = false,
            },
            git_status = {
                symbols = {
                    added = "A",
                    deleted = "D",
                    modified = "M",
                    renamed = "R",
                    untracked = "?",
                    ignored = "",
                    unstaged = "",
                    staged = "+",
                    conflict = "!",
                },
            },
        },
        window = {
            mappings = {
                ["<Tab>"] = "open",
            },
        },
        filesystem = {
            check_gitignore_in_search = false,
            filtered_items = {
                show_hidden_count = false,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = { ".git" },
            },
            follow_current_file = {
                enabled = true,
            },
            hijack_netrw_behavior = "disabled",
            commands = {
                -- over write default 'delete' command to 'trash'.
                delete = function(state)
                    local inputs = require("neo-tree.ui.inputs")
                    local path = state.tree:get_node().path
                    local msg = "Send to trash?"
                    inputs.confirm(msg, function(confirmed)
                        if not confirmed then
                            return
                        end

                        vim.fn.system({
                            "gio",
                            "trash",
                            vim.fn.fnameescape(path),
                        })
                        require("neo-tree.sources.manager").refresh(state.name)
                    end)
                end,

                -- over write default 'delete_visual' command to 'trash' x n.
                delete_visual = function(state, selected_nodes)
                    local inputs = require("neo-tree.ui.inputs")

                    -- get table items count
                    function GetTableLen(tbl)
                        local len = 0
                        for n in pairs(tbl) do
                            len = len + 1
                        end
                        return len
                    end

                    local count = GetTableLen(selected_nodes)
                    local msg = "Send " .. count .. " files to trash?"
                    inputs.confirm(msg, function(confirmed)
                        if not confirmed then
                            return
                        end
                        for _, node in ipairs(selected_nodes) do
                            vim.fn.system({
                                "gio",
                                "trash",
                                vim.fn.fnameescape(node.path),
                            })
                        end
                        require("neo-tree.sources.manager").refresh(state.name)
                    end)
                end,
            },
        },
    },
    init = toggle_neo_tree,
}
